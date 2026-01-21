import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../dashboard_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E222D),
      body: Container(
        width: 288.w,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1E222D),
        ),
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
                            _buildDrawerItem(context, Icons.home_outlined, "Dashboard", true),
                            _buildDrawerItem(context, Icons.bar_chart_outlined, "Analytics", false),
                            _buildDrawerItem(context, Icons.people_outline, "Contacts", false),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white10, height: 60),
                      Padding(
                        padding: EdgeInsets.only(left: 24.w),
                        child: Column(
                          children: [
                            _buildDrawerItem(context, Icons.settings_outlined, "Settings", false),
                            _buildDrawerItem(context, Icons.headset_mic_outlined, "Support", false),
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
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: InkWell(
        onTap: () {
          DashboardScreen.of(context)?.toggleDrawer();
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white38,
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
