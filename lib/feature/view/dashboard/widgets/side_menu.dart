import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../dashboard_screen.dart';
import '../../journal/journal_screen.dart';
import '../../plan/goal_plans_library_screen.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E222D),
      body: Container(
        width: 288.w,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF1E222D)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      SizedBox(height: 40.h),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.dashboard_rounded,
                              title: "Dashboard",
                              isActive: selectedIndex == 0,
                              onTap: () => onTabSelected(0),
                            ),
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.bar_chart_rounded,
                              title: "Analytics",
                              isActive: selectedIndex == 1,
                              onTap: () => onTabSelected(1),
                            ),
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.rocket_launch_rounded,
                              title: "Start Plan",
                              isActive: selectedIndex == 3,
                              onTap: () => onTabSelected(3),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 60),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.book_rounded,
                              title: "My Journals",
                              isActive: false,
                              onTap: () {
                                DashboardScreen.of(context)?.toggleDrawer();
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const JournalScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.folder_special_rounded,
                              title: "Saved Plans",
                              isActive: false,
                              onTap: () {
                                DashboardScreen.of(context)?.toggleDrawer();
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GoalPlansLibraryScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            _buildDrawerItem(
                              context: context,
                              icon: Icons.settings_rounded,
                              title: "Settings",
                              isActive: selectedIndex == 4,
                              onTap: () => onTabSelected(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.w, bottom: 24.h, top: 16.h),
                child: Text(
                  "Version 1.0.0",
                  style: AppTypography.body.copyWith(
                    color: Colors.white24,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, top: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
              border: Border.all(color: Colors.white10, width: 2),
            ),
            child: Icon(Icons.person, size: 40.r, color: Colors.white30),
          ),
          SizedBox(height: 16.h),
          Text(
            "Alex Sterling",
            style: AppTypography.heading.copyWith(
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Pro Trader",
            style: AppTypography.body.copyWith(
              fontSize: 14.sp,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white38,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppTypography.buttonText.copyWith(
                color: isActive ? Colors.white : Colors.white38,
                fontSize: 16.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
