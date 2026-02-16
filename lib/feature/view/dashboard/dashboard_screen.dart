import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../bottomNavigations_screen/home_screen.dart';
import '../bottomNavigations_screen/plan_tab_screen.dart';
import '../bottomNavigations_screen/analytics.dart';
import '../trade/trade_setup_screen.dart';
import '../journal/journal_screen.dart';
import '../plan/goal_plans_library_screen.dart';
import '../../service/wallet_service.dart';
import '../settings/settings_screen.dart';
import 'widgets/side_menu.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static DashboardScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<DashboardScreenState>();

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const AnalyticsScreen(),
    const Center(child: Text("Log Trade")),
    const PlanTabScreen(),
    const SettingsScreen(),
  ];

  void changePageIndex(int index) {
    if (_isDrawerOpen) toggleDrawer();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showQuickActionMenu(context);
    } else {
      changePageIndex(index);
    }
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.r, 12.r, 24.r, 32.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E222D).withOpacity(0.95),
                const Color(0xFF0D1117).withOpacity(0.98),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  "Quick Actions",
                  style: AppTypography.heading.copyWith(fontSize: 22.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "What would you like to do?",
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 32.h),
                _buildActionItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: "Update Balance",
                  subtitle: "Deposit or Withdraw funds",
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    _showWalletManager(context);
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.rocket_launch_rounded,
                  title: "Start New Trade",
                  subtitle: "Create a session and log your trades",
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const TradeSetupScreen(),
                      ),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.edit_note_rounded,
                  title: "Write Journal",
                  subtitle: "Log your thoughts and emotions",
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const JournalScreen()),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  icon: Icons.track_changes_rounded,
                  title: "Check Goals",
                  subtitle: "View your active plans and progress",
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => GoalPlansLibraryScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWalletManager(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Manage Wallet", style: AppTypography.subHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Balance: \$${WalletService.balance.toStringAsFixed(2)}",
              style: AppTypography.body,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.body,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: AppTypography.body.copyWith(
                  color: AppColors.textBody,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        WalletService.deposit(amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text("Deposit"),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        WalletService.withdraw(amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text("Withdraw"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.buttonText.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.textMain,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textBody.withOpacity(0.5),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E222D), // Side menu background
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          RepaintBoundary(
            child: SideMenu(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) => changePageIndex(index),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              double slide = 250.w * _animationController.value;
              double scale = 1.0 - (_animationController.value * 0.15);
              double radius = _animationController.value * 32.r;

              return Transform(
                transform: Matrix4.translationValues(slide, 0, 0)
                  ..scale(scale, scale, 1.0),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _isDrawerOpen ? toggleDrawer : null,
                  behavior: HitTestBehavior.opaque,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: AbsorbPointer(
                        absorbing: _isDrawerOpen,
                        child: Scaffold(
                          backgroundColor: AppColors.background,
                          body: IndexedStack(
                            index: _selectedIndex,
                            children: _screens,
                          ),
                          bottomNavigationBar: _buildBottomBar(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 90.h.clamp(80, 110).toDouble(),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, "Home"),
              _buildNavItem(1, Icons.bar_chart_rounded, "Analytics"),
              SizedBox(width: 80.w.clamp(60, 100).toDouble()), // Space for FAB
              _buildNavItem(3, Icons.account_balance_wallet_rounded, "Plan"),
              _buildNavItem(4, Icons.settings_rounded, "Settings"),
            ],
          ),
          Positioned(
            top: -20.h,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.sp.clamp(52, 68).toDouble(),
                    height: 60.sp.clamp(52, 68).toDouble(),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.textMain,
                      size: 32.sp.clamp(28, 38).toDouble(),
                    ),
                  ),
                  SizedBox(height: 6.h.clamp(4, 10).toDouble()),
                  Text(
                    "Log Trade",
                    style: AppTypography.body.copyWith(
                      fontSize: 11.sp.clamp(9, 13).toDouble(),
                      color: _selectedIndex == 2
                          ? AppColors.primary
                          : AppColors.textBody,
                      fontWeight: _selectedIndex == 2
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textBody,
            size: 28.sp.clamp(24, 32).toDouble(),
          ),
          SizedBox(height: 4.h.clamp(2, 8).toDouble()),
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12.sp.clamp(10, 14).toDouble(),
              color: isSelected ? AppColors.primary : AppColors.textBody,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
