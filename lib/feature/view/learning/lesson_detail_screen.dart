import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/premium_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/animated_entrance.dart';
import '../../service/learning_service.dart';
import '../../model/learning_model.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = LearningService.getCompletedLessonIds().contains(
      widget.lesson.id,
    );
  }

  void _markAsCompleted() {
    LearningService.markLessonAsCompleted(widget.lesson.id);
    setState(() {
      _isCompleted = true;
    });
    // Optional: Show a celebration or success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Lesson completed! Keep growing."),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      if (widget.lesson.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: GlassContainer(
                            padding: EdgeInsets.zero,
                            color: Colors.white.withOpacity(0.02),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            child: Image.asset(
                              widget.lesson.imageUrl!,
                              width: double.infinity,
                              height: 220.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                      _buildContent(),
                      SizedBox(height: 40.h),
                      _buildFooter(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: _isCompleted ? 1.0 : 0.5, // Simple visual state
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isCompleted ? AppColors.success : AppColors.primary,
                ),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            _isCompleted ? "COMPLETED" : "READING",
            style: AppTypography.label.copyWith(
              fontSize: 10.sp,
              color: _isCompleted ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final lines = widget.lesson.content.trim().split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('# ')) {
          return Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Text(
              line.replaceFirst('# ', ''),
              style: AppTypography.heading.copyWith(fontSize: 28.sp),
            ),
          );
        } else if (line.startsWith('## ')) {
          return Padding(
            padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
            child: Text(
              line.replaceFirst('## ', ''),
              style: AppTypography.subHeading.copyWith(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
          );
        } else if (line.startsWith('- ')) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• ",
                  style: TextStyle(color: AppColors.primary, fontSize: 18.sp),
                ),
                Expanded(
                  child: Text(
                    line.replaceFirst('- ', ''),
                    style: AppTypography.body,
                  ),
                ),
              ],
            ),
          );
        } else if (line.trim().isEmpty) {
          return SizedBox(height: 12.h);
        } else {
          // Detect bold text **text**
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildRichText(line),
          );
        }
      }).toList(),
    );
  }

  Widget _buildRichText(String text) {
    // Simple bold detection for demonstration
    final parts = text.split('**');
    if (parts.length < 3) {
      return Text(text, style: AppTypography.body);
    }

    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: parts[i], style: AppTypography.body));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildFooter() {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 500),
      child: Center(
        child: Column(
          children: [
            if (!_isCompleted) ...[
              const Text(
                "Did you understand the concept?",
                style: TextStyle(color: AppColors.textBody),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _markAsCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                  ),
                  child: Text(
                    "Mark as Completed",
                    style: AppTypography.buttonText,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Well done! Lesson finished.",
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Return to Academy",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
