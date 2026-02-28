import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../controller/trade_controller.dart';
import '../../model/trade_plan_model.dart';
import '../../model/journal_model.dart';
import '../../service/journal_storage_service.dart';
import 'package:intl/intl.dart';
import 'trade_plan_screen_journal.dart';
import '../../service/trade_storage_service.dart';
import '../../service/ad_service.dart';
import '../../../core/widgets/banner_ad_widget.dart';

class TradePlanScreen extends StatefulWidget {
  final TradePlanModel plan;

  const TradePlanScreen({super.key, required this.plan});

  @override
  State<TradePlanScreen> createState() => _TradePlanScreenState();
}

class _TradePlanScreenState extends State<TradePlanScreen> {
  late TradePlanModel _currentPlan;
  double _currentBalance = 0;
  double _totalProfit = 0;
  double _totalLossToRecover = 0;
  int _consecutiveLosses = 0;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _currentBalance = _currentPlan.balance;
  }

  Future<void> _onTradeOutcome(int index, bool isWin) async {
    setState(() {
      final entry = _currentPlan.entries[index];

      if (isWin) {
        _currentPlan.entries[index] = entry.copyWith(status: 'win');
        _currentBalance += entry.potentialProfit;
        _totalProfit += entry.potentialProfit;

        // WIN: Reset recovery tracking
        _totalLossToRecover = 0;
        _consecutiveLosses = 0;

        // Determine Next Move:
        // Logic: If we finished Step X, move to Step X+1.

        int currentStep = entry.step;
        int nextStep = currentStep + 1;

        if (true) {
          final nextTrade = TradeController.createNextStepTrade(
            nextStep: nextStep,
            balance: _currentBalance, // Compounding: use growing balance
            payoutPercentage: _currentPlan.payoutPercentage,
          );
          _currentPlan.entries.add(nextTrade);
        }
      } else {
        _currentPlan.entries[index] = entry.copyWith(status: 'loss');
        _currentBalance -= entry.investAmount;
        _totalProfit -= entry.investAmount;
        _consecutiveLosses++;

        // LOSS: Add to recovery pile
        _totalLossToRecover += entry.investAmount;

        // Create a Recovery Trade and INSERT it after the current one
        // detailed logic: recovery must cover 'totalLossToRecover' + original step target
        final nextTrade = TradeController.createRecoveryTrade(
          stepNumber: entry.step,
          balance: _currentBalance,
          payoutPercentage: _currentPlan.payoutPercentage,
        );

        // Insert new trade dynamically
        _currentPlan.entries.insert(index + 1, nextTrade);
      }
    });

    JournalEntryDialog.show(
      context,
      onSave: (emotion, note) async {
        setState(() {
          _currentPlan.entries[index] = _currentPlan.entries[index].copyWith(
            emotion: emotion,
            note: note,
          );
        });

        // Save to Journal Storage for the Journal Screen
        final journal = JournalModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          emotion: emotion,
          note: note,
          relatedId: _currentPlan.id,
          type: 'plan_day',
          title: '${DateFormat('EEEE').format(DateTime.now())} Journal',
        );
        await JournalStorageService().saveJournal(journal);

        // Save the updated trade plan session
        await TradeStorageService().saveTradeSession(_currentPlan);
      },
    );

    // Also save immediately after outcome change
    TradeStorageService().saveTradeSession(_currentPlan);

    if (_consecutiveLosses >= 3) {
      _showDisciplineDialog();
    } else if (_totalProfit >= _currentPlan.targetProfit - 0.1) {
      // Tolerance for float precision
      _showCompletionDialog(true);
    } else if (_totalProfit <= -_currentPlan.stopLossLimit) {
      _showCompletionDialog(false);
    }
  }

  void _showDisciplineDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '⚠️ Take a Break!',
          style: AppTypography.heading.copyWith(
            color: AppColors.accentBlue,
            fontSize: 22.sp,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: AppColors.accentBlue, size: 56.r),
            SizedBox(height: 16.h),
            Text(
              'You have lost 3 trades in a row.\n\nTo protect your mindset and capital, please take a 5-10 minute break. Step away, breathe, and reset.',
              style: AppTypography.body.copyWith(
                color: AppColors.textMain,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Reset consecutive losses after user acknowledges the warning
              // Not resetting strictly, but allowing them to continue.
              // Or should we force reset?
              setState(() {
                _consecutiveLosses = 0;
              });
            },
            child: Text(
              'I HAVE RESTED',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          isSuccess ? 'Daily Goal Achieved!' : 'Stop Loss Reached',
          style: AppTypography.heading.copyWith(
            color: isSuccess ? AppColors.success : AppColors.accentBlue,
            fontSize: 20.sp,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.emoji_events : Icons.warning_amber_rounded,
              color: isSuccess ? AppColors.success : AppColors.accentBlue,
              size: 64.r,
            ),
            SizedBox(height: 16.h),
            Text(
              isSuccess
                  ? 'Congratulations! You reached your profit target. Time to stop and enjoy your day.'
                  : 'You have reached your daily stop loss limit. Discipline is key—stop now to protect your capital.',
              style: AppTypography.body.copyWith(color: AppColors.textMain),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              'Final Profit: ${_currentPlan.currency}${_totalProfit.toStringAsFixed(2)}',
              style: AppTypography.subHeading.copyWith(
                color: _totalProfit >= 0
                    ? AppColors.success
                    : AppColors.accentBlue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AdService().showInterstitialAd();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to setup or home
            },
            child: Text(
              'CONTINUE',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The last item in the entries list is the ACTIVE or Pending trade
    // The previous items are history.
    final activeTradeIndex = _currentPlan.entries.length - 1;
    final historyCount = activeTradeIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textMain,
            size: 20.sp,
          ),
          onPressed: () {
            AdService().showInterstitialAd();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Active Session',
          style: AppTypography.subHeading.copyWith(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildSummaryHeader(),
          const Center(child: BannerAdWidget()),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Text(
              'CURRENT TRADE',
              style: AppTypography.body.copyWith(
                color: AppColors.textBody.withValues(alpha: 0.5),
                fontSize: 10.sp,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Active Trade Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: _buildActiveTradeCard(activeTradeIndex),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Row(
              children: [
                Text(
                  'HISTORY',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody.withValues(alpha: 0.5),
                    fontSize: 10.sp,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // History List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            itemCount: historyCount,
            // Show newest history on top by reversing the list indexing
            itemBuilder: (context, index) {
              // index 0 -> historyCount - 1 (most recent)
              // index 1 -> historyCount - 2
              final reversedIndex = historyCount - 1 - index;
              return _buildHistoryCard(reversedIndex);
            },
          ),
          SizedBox(height: 32.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2369FF).withOpacity(0.1),
            const Color(0xFF2369FF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF2369FF).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Balance',
                '${_currentPlan.currency}${_currentBalance.toStringAsFixed(2)}',
              ),
              _buildStatItem(
                'Profit/Loss',
                '${_currentPlan.currency}${_totalProfit.toStringAsFixed(2)}',
                valueColor: _totalProfit >= 0
                    ? AppColors.success
                    : AppColors.accentBlue,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Payout',
                '${_currentPlan.payoutPercentage}%',
                small: true,
              ),
              if (_totalLossToRecover > 0)
                _buildStatItem(
                  'Loss to Recover',
                  '${_currentPlan.currency}${_totalLossToRecover.toStringAsFixed(2)}',
                  valueColor: AppColors.accentBlue,
                  small: true,
                ),
            ],
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: (_totalProfit / _currentPlan.targetProfit).clamp(0, 1),
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${_currentPlan.currency}${_currentPlan.targetProfit}',
                style: AppTypography.body.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.textBody,
                ),
              ),
              Text(
                '${((_totalProfit / _currentPlan.targetProfit) * 100).clamp(0, 100).toStringAsFixed(1)}%',
                style: AppTypography.body.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    Color? valueColor,
    bool small = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: small ? 10.sp : 12.sp,
            color: AppColors.textBody,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.heading.copyWith(
            fontSize: small ? 14.sp : 18.sp,
            color: valueColor ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTradeCard(int index) {
    final entry = _currentPlan.entries[index];
    // Active card is prominent
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Entry No ${entry.step}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              if (entry.isRecovery)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'RECOVERY',
                    style: AppTypography.body.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'INVESTMENT',
            style: AppTypography.body.copyWith(
              color: AppColors.textBody,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_currentPlan.currency}${entry.investAmount.toStringAsFixed(2)}',
            style: AppTypography.heading.copyWith(
              fontSize: 42.sp,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            entry.isRecovery ? '2.5% of Balance' : '1.0% of Balance',
            style: AppTypography.body.copyWith(
              color: AppColors.textBody.withValues(alpha: 0.5),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Target Profit: +${_currentPlan.currency}${entry.potentialProfit.toStringAsFixed(2)}',
            style: AppTypography.body.copyWith(
              color: AppColors.success,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onTradeOutcome(index, false),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.accentBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: AppColors.accentBlue),
                          SizedBox(width: 8.w),
                          Text(
                            'LOSS',
                            style: AppTypography.buttonText.copyWith(
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: InkWell(
                  onTap: () => _onTradeOutcome(index, true),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: AppColors.success),
                          SizedBox(width: 8.w),
                          Text(
                            'WIN',
                            style: AppTypography.buttonText.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(int index) {
    final entry = _currentPlan.entries[index];
    final isWin = entry.status == 'win';

    return Opacity(
      opacity: 0.6,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isWin
                ? AppColors.success.withOpacity(0.2)
                : AppColors.accentBlue.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: isWin
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.accentBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.step}',
                  style: TextStyle(
                    color: isWin ? AppColors.success : AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invest: ${_currentPlan.currency}${entry.investAmount.toStringAsFixed(2)}',
                    style: AppTypography.subHeading.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (entry.isRecovery)
                    Text(
                      'RECOVERY ROUND',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.accentBlue,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              isWin
                  ? '+${_currentPlan.currency}${entry.potentialProfit.toStringAsFixed(2)}'
                  : '-${_currentPlan.currency}${entry.investAmount.toStringAsFixed(2)}',
              style: AppTypography.heading.copyWith(
                fontSize: 16.sp,
                color: isWin ? AppColors.success : AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
