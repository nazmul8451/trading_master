import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/plan_model.dart';
import '../../controller/plan_controller.dart';
import '../../service/plan_storage_service.dart';

class GoalSheetScreen extends StatelessWidget {
  final PlanModel plan;

  const GoalSheetScreen({super.key, required this.plan});

  void _savePlan(BuildContext context) async {
    final storage = PlanStorageService();
    await storage.savePlan(plan);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan saved successfully!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = PlanController.calculatePlan(plan);
    final finalBalance = entries.last.endBalance;
    final totalProfit = finalBalance - plan.startCapital;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Goal Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _savePlan(context),
            tooltip: 'Save Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(finalBalance, totalProfit),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildPlanRow(entry);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double finalBalance, double totalProfit) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStat('Start Capital', '\$${plan.startCapital.toStringAsFixed(2)}')),
              Expanded(child: _buildStat('Target ${plan.durationType}', '${plan.targetPercent}%', crossAxisAlignment: CrossAxisAlignment.end)),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withOpacity(0.1)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStat('Duration', '${plan.duration} ${plan.durationType}')),
              Expanded(
                child: _buildStat(
                  'Projected Final',
                  '\$${finalBalance.toStringAsFixed(2)}',
                  color: const Color(0xFF00E676),
                  isLarge: true,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value,
      {Color? color, bool isLarge = false, CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 20.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlanRow(PlanEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2369FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${plan.durationType.substring(0, plan.durationType.length - 1)} ${entry.day}',
              style: TextStyle(
                color: const Color(0xFF2369FF),
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target', style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          _formatDate(entry.date),
                          style: TextStyle(color: Colors.white30, fontSize: 10.sp),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Text(
                        '+\$${entry.targetProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: const Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Balance', style: TextStyle(color: Colors.white60, fontSize: 12.sp)),
                    Flexible(
                      child: Text(
                        '\$${entry.endBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
