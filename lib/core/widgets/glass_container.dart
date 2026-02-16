import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final bool useBackdropFilter;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.color,
    this.blur = 10.0,
    this.border,
    this.boxShadow,
    this.useBackdropFilter = false, // Default to false for better performance
  });

  @override
  Widget build(BuildContext context) {
    final containerDecoration = BoxDecoration(
      color: color ?? AppColors.surface.withOpacity(0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border:
          border ?? Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    );

    final content = Container(
      padding: padding,
      decoration: containerDecoration,
      child: child,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: useBackdropFilter
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: content,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: content,
            ),
    );
  }
}
