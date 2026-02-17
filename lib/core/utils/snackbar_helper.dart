import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    Color? color,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                icon ?? Icons.info_outline,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: (color ?? AppColors.primary).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      color: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      color: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      color: AppColors.accentBlue,
      icon: Icons.info_outline,
    );
  }
}
