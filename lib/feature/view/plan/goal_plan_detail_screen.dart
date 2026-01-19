import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/plan_model.dart';
import '../../controller/plan_controller.dart';
import '../../service/plan_storage_service.dart';

class GoalPlanDetailScreen extends StatefulWidget {
  final PlanModel plan;

  const GoalPlanDetailScreen({
    super.key,
    required this.plan,
  });

  @override
  State<GoalPlanDetailScreen> createState() => _GoalPlanDetailScreenState();
}

class _GoalPlanDetailScreenState extends State<GoalPlanDetailScreen> {
  late PlanModel _currentPlan;
  late List<PlanEntry> _entries;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _entries = PlanController.calculatePlan(_currentPlan);
  }

  void _updateStatus(int day, String status) async {
    final updatedStatuses = Map<int, String>.from(_currentPlan.dailyStatuses);
    updatedStatuses[day] = status;

    final updatedPlan = PlanModel(
      id: _currentPlan.id,
      startCapital: _currentPlan.startCapital,
      targetPercent: _currentPlan.targetPercent,
      duration: _currentPlan.duration,
      durationType: _currentPlan.durationType,
      startDate: _currentPlan.startDate,
      dailyStatuses: updatedStatuses,
    );

    setState(() {
      _currentPlan = updatedPlan;
    });

    await PlanStorageService().updatePlan(updatedPlan);
    _showFeedback(status, day);
  }

  void _showFeedback(String status, int day) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFeedbackDialog(status, day),
    );
  }

  Widget _buildFeedbackDialog(String status, int day) {
    final isHit = status == 'hit';
    final dailyTarget = _entries[day - 1].targetProfit;
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
                colors: [
                  const Color(0xFF1E222D),
                  const Color(0xFF161922),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
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
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.05),
                      ],
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
                    ? 'Amazing work! You\'ve successfully hit your target of \$${dailyTarget.toStringAsFixed(2)} for today.'
                    : 'A stop loss is simply a business cost in trading. By taking it, you\'ve shown true maturity and discipline.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 15.sp,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
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
    _entries = PlanController.calculatePlan(_currentPlan);
    final finalBalance = _entries.last.endBalance;
    final totalGain = finalBalance - _currentPlan.startCapital;
    final totalGainPercent = (totalGain / _currentPlan.startCapital * 100);

    // Find the first day without a status
    int? todayDay;
    for (int i = 1; i <= _currentPlan.duration; i++) {
      if (!_currentPlan.dailyStatuses.containsKey(i)) {
        todayDay = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const Text('Plan Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w.clamp(16, 24).toDouble()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _buildPlanHeader(totalGainPercent, finalBalance),
              if (todayDay != null) ...[
                SizedBox(height: 24.h.clamp(20, 32).toDouble()),
                _buildTodayTargetCard(todayDay),
              ],
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              Text(
                'Regular Targets',
                style: AppTypography.heading.copyWith(
                  fontSize: 20.sp.clamp(18, 24).toDouble(),
                ),
              ),
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _buildTargetsList(_entries),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTargetCard(int day) {
    final entry = _entries[day - 1];
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S TARGET",
                    style: AppTypography.body.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textBody,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _getPeriodLabel(day),
                    style: AppTypography.heading.copyWith(fontSize: 22.sp),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.track_changes, color: AppColors.primary, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _buildTargetStat("Target", "+\$${entry.targetProfit.toStringAsFixed(2)}", AppColors.success),
              SizedBox(width: 20.w),
              _buildTargetStat("End Balance", "\$${entry.endBalance.toStringAsFixed(2)}", Colors.white),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  "Target Hit",
                  Icons.check_circle_outline,
                  AppColors.success,
                  () => _updateStatus(day, 'hit'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  "Stop Loss",
                  Icons.remove_circle_outline,
                  const Color(0xFFFF5252),
                  () => _updateStatus(day, 'sl'),
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
        Text(label, style: AppTypography.body.copyWith(fontSize: 10.sp, color: AppColors.textBody)),
        Text(value, style: AppTypography.buttonText.copyWith(fontSize: 16.sp, color: color)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12.r),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 8.w),
            Text(label, style: AppTypography.buttonText.copyWith(fontSize: 14.sp, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanHeader(double totalGainPercent, double finalBalance) {
    return Container(
      padding: EdgeInsets.all(20.r.clamp(16, 24).toDouble()),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
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
                      '${_currentPlan.targetPercent}% ${_currentPlan.durationType} Target',
                      style: AppTypography.heading.copyWith(
                        fontSize: 18.sp.clamp(16, 22).toDouble(),
                      ),
                    ),
                    SizedBox(height: 4.h.clamp(2, 6).toDouble()),
                    Text(
                      'Compounding Plan • ${_currentPlan.duration} ${_currentPlan.durationType}',
                      style: AppTypography.body.copyWith(
                        fontSize: 13.sp.clamp(11, 15).toDouble(),
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w.clamp(8, 14).toDouble(),
                  vertical: 6.h.clamp(4, 8).toDouble(),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r.clamp(6, 10).toDouble()),
                ),
                child: Text(
                  'ACTIVE',
                  style: AppTypography.body.copyWith(
                    fontSize: 11.sp.clamp(9, 13).toDouble(),
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h.clamp(16, 24).toDouble()),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'STARTING CAPITAL',
                  '\$${_currentPlan.startCapital.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'TARGET GOAL',
                  '\$${finalBalance.toStringAsFixed(2)}',
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h.clamp(12, 20).toDouble()),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'TOTAL GAIN',
                  '\$${(finalBalance - _currentPlan.startCapital).toStringAsFixed(2)}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'GAIN %',
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
          style: AppTypography.body.copyWith(
            fontSize: 10.sp.clamp(8, 12).toDouble(),
            color: AppColors.textBody,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h.clamp(4, 8).toDouble()),
        Text(
          value,
          style: AppTypography.buttonText.copyWith(
            fontSize: 18.sp.clamp(16, 22).toDouble(),
            color: color ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetsList(List<PlanEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final profit = entry.endBalance - entry.startBalance;
        final isLast = index == entries.length - 1;
        final status = _currentPlan.dailyStatuses[entry.day];
        final isCompleted = status != null;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h.clamp(8, 16).toDouble()),
          padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
          decoration: BoxDecoration(
            color: isCompleted 
                ? (status == 'hit' ? AppColors.success : AppColors.accentBlue).withOpacity(0.05)
                : (isLast ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface),
            borderRadius: BorderRadius.circular(12.r.clamp(10, 16).toDouble()),
            border: Border.all(
              color: isCompleted
                  ? (status == 'hit' ? AppColors.success : AppColors.accentBlue).withOpacity(0.3)
                  : (isLast ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
              width: (isLast || isCompleted) ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w.clamp(28, 36).toDouble(),
                        height: 32.h.clamp(28, 36).toDouble(),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (status == 'hit' ? AppColors.success : AppColors.accentBlue)
                              : (isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: status != null
                              ? Icon(status == 'hit' ? Icons.check : Icons.close, color: Colors.white, size: 16.sp)
                              : Text(
                                  '${entry.day}',
                                  style: AppTypography.buttonText.copyWith(
                                    fontSize: 14.sp.clamp(12, 16).toDouble(),
                                    color: isLast ? AppColors.textMain : AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w.clamp(8, 16).toDouble()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPeriodLabel(entry.day),
                            style: AppTypography.subHeading.copyWith(
                              fontSize: 15.sp.clamp(13, 17).toDouble(),
                            ),
                          ),
                          if (isCompleted)
                            Text(
                              status == 'hit' ? 'Target Achieved' : 'Stop Loss Taken',
                              style: AppTypography.body.copyWith(
                                fontSize: 11.sp.clamp(9, 13).toDouble(),
                                color: status == 'hit' ? AppColors.success : AppColors.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (isLast)
                            Text(
                              'Final Target',
                              style: AppTypography.body.copyWith(
                                fontSize: 11.sp.clamp(9, 13).toDouble(),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    isCompleted 
                        ? (status == 'hit' ? Icons.stars : Icons.verified_user)
                        : (isLast ? Icons.flag : Icons.trending_up),
                    color: isCompleted
                        ? (status == 'hit' ? AppColors.success : AppColors.accentBlue)
                        : (isLast ? AppColors.primary : AppColors.textBody),
                    size: 20.sp.clamp(18, 24).toDouble(),
                  ),
                ],
              ),
              SizedBox(height: 12.h.clamp(8, 16).toDouble()),
              Container(
                padding: EdgeInsets.all(12.r.clamp(10, 14).toDouble()),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r.clamp(6, 10).toDouble()),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Start Balance',
                      '\$${entry.startBalance.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 8.h.clamp(6, 10).toDouble()),
                    _buildDetailRow(
                      'Target Profit (${_currentPlan.targetPercent}%)',
                      '+\$${profit.toStringAsFixed(2)}',
                      valueColor: AppColors.success,
                    ),
                    SizedBox(height: 8.h.clamp(6, 10).toDouble()),
                    Divider(
                      color: AppColors.border,
                      height: 1,
                    ),
                    SizedBox(height: 8.h.clamp(6, 10).toDouble()),
                    _buildDetailRow(
                      'End Balance',
                      '\$${entry.endBalance.toStringAsFixed(2)}',
                      isBold: true,
                      valueColor: isLast ? AppColors.primary : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 12.sp.clamp(10, 14).toDouble(),
            color: AppColors.textBody,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: AppTypography.buttonText.copyWith(
            fontSize: 13.sp.clamp(11, 15).toDouble(),
            color: valueColor ?? AppColors.textMain,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel(int day) {
    switch (_currentPlan.durationType) {
      case 'Days':
        return 'Day $day';
      case 'Weeks':
        return 'Week $day';
      case 'Months':
        return 'Month $day';
      default:
        return 'Period $day';
    }
  }
}
