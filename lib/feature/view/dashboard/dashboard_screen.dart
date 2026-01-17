import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../bottomNavigations_screen/home_screen.dart';

import '../bottomNavigations_screen/plane.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;



  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Analytics")),
    const Center(child: Text("Log Trade")),
    const PlaneScreen(),
    const Center(child: Text("Settings")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 90.h.clamp(80, 110).toDouble(),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
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
                      color: _selectedIndex == 2 ? AppColors.primary : AppColors.textBody,
                      fontWeight: _selectedIndex == 2 ? FontWeight.w600 : FontWeight.normal,
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
