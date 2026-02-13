import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../service/trade_storage_service.dart';
import '../../model/trade_plan_model.dart';
import 'goal_plan_detail_screen.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';

class GoalPlansLibraryScreen extends StatefulWidget {
  const GoalPlansLibraryScreen({super.key});

  @override
  State<GoalPlansLibraryScreen> createState() => _GoalPlansLibraryScreenState();
}

class _GoalPlansLibraryScreenState extends State<GoalPlansLibraryScreen>
    with SingleTickerProviderStateMixin {
  final TradeStorageService _storage = TradeStorageService();
  List<TradePlanModel> _allPlans = [];
  List<TradePlanModel> _filteredPlans = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<String> _selectedPlanIds = {};
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Days', 'Weeks', 'Months'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _filterPlans();
    }
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final allPlans = _storage.getAllTradeSessions();
    allPlans.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _allPlans = allPlans;
        _isLoading = false;
      });
      _filterPlans();
    }
  }

  void _filterPlans() {
    final selectedTab = _tabs[_tabController.index];
    setState(() {
      if (selectedTab == 'All') {
        _filteredPlans = _allPlans;
      } else {
        _filteredPlans = _allPlans
            .where((plan) => plan.durationType == selectedTab)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedPlanIds.length} Selected' : 'Library',
          style: AppTypography.heading.copyWith(fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSelectionMode ? Icons.close : Icons.arrow_back_ios_new,
              size: 18,
            ),
          ),
          onPressed: () =>
              _isSelectionMode ? _exitSelectionMode() : Navigator.pop(context),
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onPressed: _selectedPlanIds.isEmpty
                      ? null
                      : _showDeleteConfirmation,
                ),
              ]
            : null,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: _buildTabBar(),
        ),
      ),
      body: PremiumBackground(
        child: _isLoading
            ? _buildLoadingState()
            : _filteredPlans.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                itemCount: _filteredPlans.length,
                itemBuilder: (context, index) {
                  return AnimatedEntrance(
                    delay: Duration(milliseconds: 50 * index),
                    child: _buildPlanCard(_filteredPlans[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      height: 56.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textBody.withOpacity(0.7),
        labelStyle: AppTypography.buttonText.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto', // Ensure consistent premium font if applicable
        ),
        unselectedLabelStyle: AppTypography.body.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: _tabs
            .map(
              (tab) => Tab(
                height: 48.h,
                child: Center(child: Text(tab, textAlign: TextAlign.center)),
              ),
            )
            .toList(),
        splashBorderRadius: BorderRadius.circular(26.r),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading Plans...',
            style: AppTypography.body.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 48.sp,
              color: AppColors.textBody.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Plans Found',
            style: AppTypography.subHeading.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(TradePlanModel plan) {
    final completedEntries = plan.entries
        .where((e) => e.status != 'pending')
        .length;
    final totalEntries = plan.entries.length;
    final double progress = totalEntries > 0
        ? (completedEntries / totalEntries)
        : 0;
    final isSelected = _selectedPlanIds.contains(plan.id);

    return GestureDetector(
      onLongPress: () => _enterSelectionMode(plan.id),
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(plan.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalPlanDetailScreen(plan: plan),
            ),
          );
        }
      },
      child: GlassContainer(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        borderRadius: 20.r,
        color: isSelected
            ? AppColors.primary.withOpacity(0.2)
            : Colors.white.withOpacity(0.03),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withOpacity(0.05),
        ),
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
                        Text(
                          '${plan.targetProfit}% Daily',
                          style: AppTypography.heading.copyWith(
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            plan.durationType.toUpperCase(),
                            style: AppTypography.label.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${plan.entries.length} Steps • ${plan.currency}${plan.balance.toStringAsFixed(0)} Capital',
                      style: AppTypography.body.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textBody.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(plan.id),
                    activeColor: AppColors.primary,
                    shape: CircleBorder(),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textBody.withOpacity(0.5),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppTypography.label.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTypography.label.copyWith(
                        color: progress == 1
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(
                      progress == 1 ? AppColors.success : AppColors.primary,
                    ),
                    minHeight: 6.h,
                  ),
                ),
              ],
            ),
            if (!_isSelectionMode) ...[
              SizedBox(height: 20.h),
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
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Text(
                    'Continue Plan',
                    style: AppTypography.buttonText.copyWith(
                      color: AppColors.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
        if (_selectedPlanIds.isEmpty) _isSelectionMode = false;
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
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Plans?',
          style: AppTypography.heading.copyWith(fontSize: 20.sp),
        ),
        content: Text(
          'Are you sure you want to delete $count plan(s)? This cannot be undone.',
          style: AppTypography.body.copyWith(color: AppColors.textBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonText.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete', style: AppTypography.buttonText),
          ),
        ],
      ),
    );

    if (result == true) {
      for (var id in _selectedPlanIds) {
        await _storage.deleteSession(id);
      }
      _exitSelectionMode();
      _loadPlans();
    }
  }
}
