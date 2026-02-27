import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../service/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    final authService = AuthService();

    if (authService.isLoggedIn) {
      // Background sync disabled as per user request to stick with GetStorage for now
      // SyncService.syncAllData();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      // Check if it's the first time
      final box = GetStorage();
      final bool isFirstTime = box.read('isFirstTime') ?? true;

      if (mounted) {
        if (isFirstTime) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else {
          // User not logged in, go to login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.8),
              AppColors.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon/Logo
                  Container(
                    width: 120.sp,
                    height: 120.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.trending_up,
                      size: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // App Name
                  Text(
                    'Trading Master',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Tagline
                  Text(
                    'Master Your Trading Psychology',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textBody,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 50.h),

                  // Loading indicator
                  SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: SpinKitFadingCircle(
                      color: AppColors.primary,
                      size: 40.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
