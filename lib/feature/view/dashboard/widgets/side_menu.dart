import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../dashboard_screen.dart';
import '../../journal/journal_screen.dart';
import '../../plan/goal_plans_library_screen.dart';
import 'package:get_storage/get_storage.dart';

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
        width: 280.w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF161922),
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.dashboard_rounded,
                      title: "Market Center",
                      isActive: selectedIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.analytics_rounded,
                      title: "Performance",
                      isActive: selectedIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.auto_awesome_motion_rounded,
                      title: "Trading Plans",
                      isActive: selectedIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Divider(
                  color: Colors.white.withOpacity(0.05),
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.auto_stories_rounded,
                      title: "Trade Journal",
                      isActive: false,
                      onTap: () {
                        DashboardScreen.of(context)?.toggleDrawer();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JournalScreen(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.folder_copy_rounded,
                      title: "Saved Blueprint",
                      isActive: false,
                      onTap: () {
                        DashboardScreen.of(context)?.toggleDrawer();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalPlansLibraryScreen(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.settings_suggest_rounded,
                      title: "Preferences",
                      isActive: selectedIndex == 4,
                      onTap: () => onTabSelected(4),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.primary,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Pro Cloud",
                            style: AppTypography.label.copyWith(
                              color: AppColors.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Build v1.0.4 - Canary",
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withOpacity(0.15),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final storage = GetStorage();
    final name = storage.read('user_name') ?? "Trader";
    final title = storage.read('user_title') ?? "Master Trader";

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, const Color(0xFF6366F1)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "T",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.heading.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.3),
                  size: 20.sp,
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: AppTypography.buttonText.copyWith(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    fontSize: 15.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
