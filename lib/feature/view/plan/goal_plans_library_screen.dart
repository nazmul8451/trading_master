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
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<String> _selectedPlanIds = {};

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading delay to show progress indicator
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _plans = _storage.getPlansByType(_selectedFilter);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        title: Text(
          _isSelectionMode
              ? '${_selectedPlanIds.length} selected'
              : 'Goal Plans Library',
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selectedPlanIds.isEmpty ? null : _showDeleteConfirmation,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : SingleChildScrollView(
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w.clamp(50, 70).toDouble(),
            height: 60.h.clamp(50, 70).toDouble(),
            child: CircularProgressIndicator(
              strokeWidth: 4.w.clamp(3, 5).toDouble(),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 24.h.clamp(20, 28).toDouble()),
          Text(
            'Loading your plans...',
            style: AppTypography.body.copyWith(
              fontSize: 14.sp.clamp(12, 16).toDouble(),
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r.clamp(20, 28).toDouble()),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.track_changes_outlined,
              size: 64.sp.clamp(56, 72).toDouble(),
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 24.h.clamp(20, 28).toDouble()),
          Text(
            'No ${_selectedFilter.toLowerCase()} plans yet',
            style: AppTypography.subHeading.copyWith(
              fontSize: 18.sp.clamp(16, 20).toDouble(),
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h.clamp(6, 10).toDouble()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w.clamp(32, 48).toDouble()),
            child: Text(
              'Create your first goal plan to start tracking your trading journey',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 14.sp.clamp(12, 16).toDouble(),
                color: AppColors.textBody,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan, int index) {
    final entries = PlanController.calculatePlan(plan);
    final finalBalance = entries.last.endBalance;
    final currentProgress = ((finalBalance - plan.startCapital) / plan.startCapital * 100);
    final isSelected = _selectedPlanIds.contains(plan.id);

    return GestureDetector(
      onLongPress: () {
        _enterSelectionMode(plan.id);
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(plan.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h.clamp(12, 20).toDouble()),
        padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
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
              _isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        _toggleSelection(plan.id);
                      },
                      activeColor: AppColors.primary,
                    )
                  : Container(
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
              _buildStatColumn('STARTING CAPITAL', '${plan.currency}${plan.startCapital.toStringAsFixed(2)}'),
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
                'Goal: ${plan.currency}${finalBalance.toStringAsFixed(2)}',
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
              onPressed: _isSelectionMode ? null : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalPlanDetailScreen(plan: plan),
                  ),
                );
                _loadPlans();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSelectionMode 
                    ? AppColors.surface 
                    : AppColors.primary,
                foregroundColor: _isSelectionMode 
                    ? AppColors.textBody 
                    : AppColors.textMain,
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

  void _enterSelectionMode(String planId) {
    setState(() {
      _isSelectionMode = true;
      _selectedPlanIds.add(planId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPlanIds.clear();
    });
  }

  void _toggleSelection(String planId) {
    setState(() {
      if (_selectedPlanIds.contains(planId)) {
        _selectedPlanIds.remove(planId);
        if (_selectedPlanIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPlanIds.add(planId);
      }
    });
  }

  Future<void> _showDeleteConfirmation() async {
    final count = _selectedPlanIds.length;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
        ),
        title: Text(
          'Delete Plan${count > 1 ? 's' : ''}?',
          style: AppTypography.subHeading.copyWith(
            fontSize: 18.sp.clamp(16, 20).toDouble(),
          ),
        ),
        content: Text(
          'Are you sure you want to delete $count plan${count > 1 ? 's' : ''}? This action cannot be undone.',
          style: AppTypography.body.copyWith(
            fontSize: 14.sp.clamp(12, 16).toDouble(),
            color: AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonText.copyWith(
                fontSize: 14.sp.clamp(12, 16).toDouble(),
                color: AppColors.textBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r.clamp(6, 10).toDouble()),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTypography.buttonText.copyWith(
                fontSize: 14.sp.clamp(12, 16).toDouble(),
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteSelectedPlans();
    }
  }

  Future<void> _deleteSelectedPlans() async {
    final count = _selectedPlanIds.length;
    await _storage.deletePlansByIds(_selectedPlanIds.toList());
    _exitSelectionMode();
    await _loadPlans();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count plan${count > 1 ? 's' : ''} deleted successfully',
            style: AppTypography.body.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r.clamp(6, 10).toDouble()),
          ),
        ),
      );
    }
  }
}
