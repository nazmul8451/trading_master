import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/plan_model.dart';
import '../../controller/plan_controller.dart';

class GoalPlanDetailScreen extends StatelessWidget {
  final PlanModel plan;

  const GoalPlanDetailScreen({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final entries = PlanController.calculatePlan(plan);
    final finalBalance = entries.last.endBalance;
    final totalGain = finalBalance - plan.startCapital;
    final totalGainPercent = (totalGain / plan.startCapital * 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              Text(
                'Regular Targets',
                style: AppTypography.heading.copyWith(
                  fontSize: 20.sp.clamp(18, 24).toDouble(),
                ),
              ),
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _buildTargetsList(entries),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
            ],
          ),
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
                      '${plan.targetPercent}% ${plan.durationType} Target',
                      style: AppTypography.heading.copyWith(
                        fontSize: 18.sp.clamp(16, 22).toDouble(),
                      ),
                    ),
                    SizedBox(height: 4.h.clamp(2, 6).toDouble()),
                    Text(
                      'Compounding Plan • ${plan.duration} ${plan.durationType}',
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
                  '\$${plan.startCapital.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'TARGET GOAL',
                  '\$${finalBalance.toStringAsFixed(2)}',
                  color: const Color(0xFF3B82F6),
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
                  '\$${(finalBalance - plan.startCapital).toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'GAIN %',
                  '${totalGainPercent.toStringAsFixed(1)}%',
                  color: const Color(0xFF10B981),
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
        final isFirst = index == 0;
        final isLast = index == entries.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h.clamp(8, 16).toDouble()),
          padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
          decoration: BoxDecoration(
            color: isLast 
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r.clamp(10, 16).toDouble()),
            border: Border.all(
              color: isLast 
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: isLast ? 2 : 1,
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
                          color: isLast 
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.day}',
                            style: AppTypography.buttonText.copyWith(
                              fontSize: 14.sp.clamp(12, 16).toDouble(),
                              color: isLast 
                                  ? AppColors.textMain
                                  : AppColors.primary,
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
                          if (isFirst)
                            Text(
                              'Starting Point',
                              style: AppTypography.body.copyWith(
                                fontSize: 11.sp.clamp(9, 13).toDouble(),
                                color: AppColors.textBody,
                              ),
                            ),
                          if (isLast)
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
                    isLast ? Icons.flag : Icons.trending_up,
                    color: isLast ? AppColors.primary : AppColors.textBody,
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
                      'Target Profit (${plan.targetPercent}%)',
                      '+\$${profit.toStringAsFixed(2)}',
                      valueColor: const Color(0xFF10B981),
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
    switch (plan.durationType) {
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
