import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/premium_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/animated_entrance.dart';
import '../../service/learning_service.dart';
import '../../model/learning_model.dart';
import 'lesson_detail_screen.dart';
import 'widgets/compound_calculator_screen.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = LearningService.getProgress();
    final completedIds = LearningService.getCompletedLessonIds();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildHeader(context),
                SizedBox(height: 32.h),
                _buildProgressCard(progress),
                SizedBox(height: 32.h),
                _buildToolsSection(context),
                SizedBox(height: 40.h),
                Text(
                  "Learning Categories",
                  style: AppTypography.heading.copyWith(fontSize: 22.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Choose a topic to master your trading skills.",
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 24.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: LearningService.categories.length,
                  itemBuilder: (context, index) {
                    final category = LearningService.categories[index];
                    return AnimatedEntrance(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildCategoryCard(category, completedIds),
                    );
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: EdgeInsets.all(12.r),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trader's Academy",
              style: AppTypography.heading.copyWith(fontSize: 24.sp),
            ),
            Text(
              "Knowledge is your best edge",
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Growth Tools",
          style: AppTypography.heading.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 16.h),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompoundCalculatorScreen(),
            ),
          ),
          child: GlassContainer(
            padding: EdgeInsets.all(20.r),
            color: AppColors.secondary.withOpacity(0.1),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calculate_rounded,
                    color: AppColors.secondary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Compound Growth Calculator",
                        style: AppTypography.buttonText.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        "Visualize your path to a big account.",
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress) {
    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      borderRadius: 24.r,
      color: AppColors.primary.withOpacity(0.05),
      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOUR PROGRESS",
                style: AppTypography.label.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: AppTypography.heading.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10.h,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "${LearningService.getCompletedLessonIds().length} of ${LearningService.getAllLessons().length} lessons completed",
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    LearningCategory category,
    List<String> completedIds,
  ) {
    final completedInCategory = category.lessons
        .where((l) => completedIds.contains(l.id))
        .length;
    final totalInCategory = category.lessons.length;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 20.r,
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: AppTypography.buttonText.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        "$completedInCategory/$totalInCategory lessons",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textBody.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            children: category.lessons.map((lesson) {
              final isCompleted = completedIds.contains(lesson.id);
              return _buildLessonItem(lesson, isCompleted);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson, bool isCompleted) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailScreen(lesson: lesson),
          ),
        );
        setState(() {}); // Refresh progress
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.play_circle_outline_rounded,
              color: isCompleted
                  ? AppColors.success
                  : AppColors.textBody.withOpacity(0.4),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                lesson.title,
                style: AppTypography.body.copyWith(
                  color: isCompleted
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              "${lesson.estimatedMinutes}m",
              style: AppTypography.caption.copyWith(fontSize: 10.sp),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.2),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
