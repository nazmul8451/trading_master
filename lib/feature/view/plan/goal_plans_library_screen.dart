import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../service/plan_storage_service.dart';
import '../../model/plan_model.dart';
import '../../controller/plan_controller.dart';
import 'goal_plan_detail_screen.dart';

class GoalPlansLibraryScreen extends StatefulWidget {
  const GoalPlansLibraryScreen({super.key});

  @override
  State<GoalPlansLibraryScreen> createState() => _GoalPlansLibraryScreenState();
}

class _GoalPlansLibraryScreenState extends State<GoalPlansLibraryScreen> {
  final PlanStorageService _storage = PlanStorageService();
  String _selectedFilter = 'Days';
  List<PlanModel> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    setState(() {
      _plans = _storage.getPlansByType(_selectedFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Goal Plans Library'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w.clamp(16, 24).toDouble()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _buildFilterTabs(),
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _plans.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _plans.length,
                      itemBuilder: (context, index) {
                        return _buildPlanCard(_plans[index], index);
                      },
                    ),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('Days', 'Daily'),
        SizedBox(width: 12.w.clamp(8, 16).toDouble()),
        _buildFilterTab('Weeks', 'Weekly'),
        SizedBox(width: 12.w.clamp(8, 16).toDouble()),
        _buildFilterTab('Months', 'Monthly'),
      ],
    );
  }

  Widget _buildFilterTab(String type, String label) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = type;
          _loadPlans();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w.clamp(12, 20).toDouble(),
          vertical: 8.h.clamp(6, 12).toDouble(),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8.r.clamp(6, 12).toDouble()),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.buttonText.copyWith(
            fontSize: 14.sp.clamp(12, 16).toDouble(),
            color: isSelected ? AppColors.textMain : AppColors.textBody,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.r.clamp(24, 40).toDouble()),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.track_changes,
              size: 64.sp.clamp(56, 72).toDouble(),
              color: AppColors.textBody.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h.clamp(12, 20).toDouble()),
            Text(
              'No ${_selectedFilter.toLowerCase()} plans yet',
              style: AppTypography.subHeading.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan, int index) {
    final entries = PlanController.calculatePlan(plan);
    final finalBalance = entries.last.endBalance;
    final currentProgress = ((finalBalance - plan.startCapital) / plan.startCapital * 100);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h.clamp(12, 20).toDouble()),
      padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
        border: Border.all(color: AppColors.border),
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
                      style: AppTypography.subHeading.copyWith(
                        fontSize: 16.sp.clamp(14, 18).toDouble(),
                      ),
                    ),
                    SizedBox(height: 4.h.clamp(2, 6).toDouble()),
                    Text(
                      'Compounding • ${plan.duration} ${plan.durationType}',
                      style: AppTypography.body.copyWith(
                        fontSize: 12.sp.clamp(10, 14).toDouble(),
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w.clamp(6, 12).toDouble(),
                  vertical: 4.h.clamp(2, 6).toDouble(),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r.clamp(4, 8).toDouble()),
                ),
                child: Text(
                  'ACTIVE',
                  style: AppTypography.body.copyWith(
                    fontSize: 10.sp.clamp(8, 12).toDouble(),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h.clamp(12, 20).toDouble()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('STARTING CAPITAL', '\$${plan.startCapital.toStringAsFixed(2)}'),
              _buildStatColumn('CURRENT PROGRESS', '${currentProgress.toStringAsFixed(1)}%', 
                color: AppColors.accentBlue),
            ],
          ),
          SizedBox(height: 12.h.clamp(8, 16).toDouble()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day 1 / ${plan.duration}',
                style: AppTypography.body.copyWith(
                  fontSize: 12.sp.clamp(10, 14).toDouble(),
                  color: AppColors.textBody,
                ),
              ),
              Text(
                'Goal: \$${finalBalance.toStringAsFixed(2)}',
                style: AppTypography.body.copyWith(
                  fontSize: 12.sp.clamp(10, 14).toDouble(),
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h.clamp(12, 20).toDouble()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalPlanDetailScreen(plan: plan),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textMain,
                padding: EdgeInsets.symmetric(
                  vertical: 12.h.clamp(10, 14).toDouble(),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r.clamp(6, 10).toDouble()),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: AppTypography.buttonText.copyWith(
                      fontSize: 14.sp.clamp(12, 16).toDouble(),
                    ),
                  ),
                  SizedBox(width: 8.w.clamp(6, 10).toDouble()),
                  Icon(
                    Icons.arrow_forward,
                    size: 16.sp.clamp(14, 18).toDouble(),
                  ),
                ],
              ),
            ),
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
        SizedBox(height: 4.h.clamp(2, 6).toDouble()),
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
}
