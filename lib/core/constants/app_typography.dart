import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get heading => TextStyle(
        fontSize: 32.sp.clamp(28, 36).toDouble(),
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
        height: 1.2,
      );

  static TextStyle get subHeading => TextStyle(
        fontSize: 18.sp.clamp(16, 20).toDouble(),
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
        height: 1.5,
      );

  static TextStyle get body => TextStyle(
        fontSize: 14.sp.clamp(12, 16).toDouble(),
        fontWeight: FontWeight.normal,
        color: AppColors.textBody,
        height: 1.6,
      );

  static TextStyle get buttonText => TextStyle(
        fontSize: 16.sp.clamp(14, 18).toDouble(),
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      );

  static TextStyle get protocolText => TextStyle(
        fontSize: 12.sp.clamp(10, 14).toDouble(),
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: AppColors.textMain,
      );
}
