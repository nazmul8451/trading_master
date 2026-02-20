import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/trade_plan_model.dart';
import 'package:intl/intl.dart';
import '../../service/trade_storage_service.dart';
import '../../model/journal_model.dart';
import '../../service/journal_storage_service.dart';
import '../trade/trade_plan_screen_journal.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';
import '../../../core/utils/snackbar_helper.dart';

class GoalPlanDetailScreen extends StatefulWidget {
  final TradePlanModel plan;

  const GoalPlanDetailScreen({super.key, required this.plan});

  @override
  State<GoalPlanDetailScreen> createState() => _GoalPlanDetailScreenState();
}

class _GoalPlanDetailScreenState extends State<GoalPlanDetailScreen> {
  late TradePlanModel _currentPlan;
  late List<TradeEntryModel> _entries;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _entries = _currentPlan.entries;
  }

  void _updateStatus(int step, String status) async {
    final updatedEntries = _entries.map((entry) {
      if (entry.step == step) {
        return TradeEntryModel(
          step: entry.step,
          investAmount: entry.investAmount,
          potentialProfit: entry.potentialProfit,
          status: status,
          isRecovery: entry.isRecovery,
          emotion: entry.emotion,
          note: entry.note,
        );
      }
      return entry;
    }).toList();

    final updatedPlan = TradePlanModel(
      id: _currentPlan.id,
      balance: _currentPlan.balance,
      targetProfit: _currentPlan.targetProfit,
      stopLossLimit: _currentPlan.stopLossLimit,
      payoutPercentage: _currentPlan.payoutPercentage,
      currency: _currentPlan.currency,
      durationType: _currentPlan.durationType,
      date: _currentPlan.date,
      entries: updatedEntries,
    );

    setState(() {
      _currentPlan = updatedPlan;
      _entries = updatedEntries;
    });

    await TradeStorageService().saveTradeSession(updatedPlan);
    _showFeedback(status, step);
  }

  void _showFeedback(String status, int step) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFeedbackDialog(status, step),
    );
  }

  Widget _buildFeedbackDialog(String status, int step) {
    final isHit = status == 'hit';
    final dailyTarget = _entries[step - 1].potentialProfit;
    final color = isHit ? AppColors.success : AppColors.accentBlue;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.r, 64.r, 24.r, 24.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1E222D), const Color(0xFF161922)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHit ? 'Congratulations!' : 'Stay Disciplined!',
                  style: AppTypography.heading.copyWith(
                    fontSize: 26.sp,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHit ? Icons.stars : Icons.security,
                        color: color,
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isHit ? 'DAILY SUCCESS' : 'DISCIPLINE MAINTAINED',
                        style: AppTypography.body.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  isHit
                      ? 'Amazing work! You\'ve successfully hit your target of ${_currentPlan.currency}${dailyTarget.toStringAsFixed(2)} for today.'
                      : 'A stop loss is simply a business cost in trading. By taking it, you\'ve shown true maturity and discipline.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 15.sp,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                InkWell(
                  onTap: () {
                    JournalEntryDialog.show(
                      context,
                      onSave: (emotion, note) async {
                        final journal = JournalModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          date: DateTime.now(),
                          emotion: emotion,
                          note: note,
                          relatedId: _currentPlan.id,
                          type: 'plan_day',
                          title:
                              '${DateFormat('EEEE').format(DateTime.now())} Journal',
                        );
                        await JournalStorageService().saveJournal(journal);
                        if (mounted) {
                          SnackbarHelper.showSuccess(
                            context,
                            'Journal entry saved!',
                          );
                        }
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note, color: color, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Journal Reflection',
                          style: AppTypography.buttonText.copyWith(
                            color: color,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFE0E0E0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: AppTypography.buttonText.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to Library
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Return to Dashboard',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textBody.withOpacity(0.7),
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -42.r,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHit ? Icons.emoji_events : Icons.shield,
                  color: Colors.white,
                  size: 48.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double finalBalance;
    if (_entries.isNotEmpty) {
      final lastEntry = _entries.last;
      finalBalance = lastEntry.investAmount + lastEntry.potentialProfit;
    } else {
      finalBalance = _currentPlan.balance;
    }

    final totalGain = finalBalance - _currentPlan.balance;
    final totalGainPercent = _currentPlan.balance > 0
        ? (totalGain / _currentPlan.balance * 100)
        : 0.0;

    int? currentStep;
    for (var entry in _entries) {
      if (entry.status == 'pending') {
        currentStep = entry.step;
        break;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Plan Details',
          style: AppTypography.heading.copyWith(fontSize: 18.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 20.w.clamp(16, 24).toDouble(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ), // AppBar spacing
              AnimatedEntrance(
                child: _buildPlanHeader(totalGainPercent, finalBalance),
              ),
              if (currentStep != null) ...[
                SizedBox(height: 24.h),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  offset: const Offset(0.2, 0),
                  child: _buildTodayTargetCard(currentStep),
                ),
              ],
              SizedBox(height: 32.h),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Regular Targets',
                  style: AppTypography.heading.copyWith(fontSize: 20.sp),
                ),
              ),
              SizedBox(height: 16.h),
              _buildTargetsList(_entries),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTargetCard(int step) {
    var entry = _entries[step - 1]; // Fallback to safe index logic if needed
    // Safety check just in case, though logically step should be valid
    if (step > _entries.length) return SizedBox();

    final endBalance = entry.investAmount + entry.potentialProfit;

    return GlassContainer(
      padding: EdgeInsets.all(20.r),
      borderRadius: 24.r,
      color: AppColors.surface.withOpacity(0.4),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "TODAY'S TARGET",
                          style: AppTypography.label.copyWith(
                            fontSize: 10.sp,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _getPeriodLabel(step),
                    style: AppTypography.heading.copyWith(fontSize: 22.sp),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentBlue],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.track_changes,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              _buildTargetStat(
                "Target Profit",
                "+${_currentPlan.currency}${entry.potentialProfit.toStringAsFixed(2)}",
                AppColors.success,
              ),
              SizedBox(width: 20.w),
              _buildTargetStat(
                "End Balance",
                "${_currentPlan.currency}${endBalance.toStringAsFixed(2)}",
                Colors.white,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "Hit Target",
                  Icons.check_circle,
                  AppColors.success,
                  () => _updateStatus(step, 'hit'),
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  "Stop Loss",
                  Icons.security,
                  const Color(0xFFFF5252),
                  () => _updateStatus(step, 'sl'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            fontSize: 10.sp,
            color: AppColors.textBody.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.heading.copyWith(
            fontSize: 20.sp,
            color: color,
            shadows: [Shadow(color: color.withOpacity(0.3), blurRadius: 10)],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: color.withOpacity(isPrimary ? 0.5 : 0.3)),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTypography.buttonText.copyWith(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader(double totalGainPercent, double finalBalance) {
    return GlassContainer(
      padding: EdgeInsets.all(24.r),
      borderRadius: 24.r,
      color: Colors.white.withOpacity(0.03),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentPlan.targetProfit}% Daily Growth',
                      style: AppTypography.heading.copyWith(fontSize: 20.sp),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12.sp,
                          color: AppColors.textBody,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${_currentPlan.entries.length} Steps Blueprint',
                          style: AppTypography.body.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Text(
                  'ACTIVE',
                  style: AppTypography.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'STARTING CAPITAL',
                  '${_currentPlan.currency}${_currentPlan.balance.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'TARGET GOAL',
                  '${_currentPlan.currency}${finalBalance.toStringAsFixed(2)}',
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'TOTAL PROFIT',
                  '${_currentPlan.currency}${(finalBalance - _currentPlan.balance).toStringAsFixed(2)}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'GROWTH',
                  '${totalGainPercent.toStringAsFixed(1)}%',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 10.sp,
            color: AppColors.textBody.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.heading.copyWith(
            fontSize: 18.sp,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetsList(List<TradeEntryModel> entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final status = entry.status;
        final isCompleted = status != 'pending';

        return AnimatedEntrance(
          delay: Duration(
            milliseconds: 30 * index,
          ), // Slightly lower delay for long lists
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isCompleted
                  ? (status == 'hit' ? AppColors.success : AppColors.accentBlue)
                        .withOpacity(0.05)
                  : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isCompleted
                    ? (status == 'hit'
                              ? AppColors.success
                              : AppColors.accentBlue)
                          .withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (status == 'hit'
                              ? AppColors.success
                              : AppColors.accentBlue)
                        : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            status == 'hit' ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 18.sp,
                          )
                        : Text(
                            '${entry.step}',
                            style: AppTypography.buttonText.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.textBody,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPeriodLabel(entry.step),
                        style: AppTypography.body.copyWith(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Target: ${_currentPlan.currency}${entry.potentialProfit.toStringAsFixed(2)}",
                        style: AppTypography.body.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (status == 'hit'
                                  ? AppColors.success
                                  : AppColors.accentBlue)
                              .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      status == 'hit' ? 'HIT' : 'SL',
                      style: AppTypography.label.copyWith(
                        color: status == 'hit'
                            ? AppColors.success
                            : AppColors.accentBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPeriodLabel(int index) {
    return 'Day $index';
  }
}
