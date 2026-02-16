import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class JournalEntryDialog {
  static void show(
    BuildContext context, {
    required Function(String emotion, String note) onSave,
  }) {
    String selectedEmotion = 'Calm';
    final noteController = TextEditingController();
    final emotions = [
      {
        'name': 'Calm',
        'icon': Icons.sentiment_satisfied_alt,
        'color': Colors.green,
      },
      {
        'name': 'Fear',
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.orange,
      },
      {
        'name': 'Greed',
        'icon': Icons.monetization_on_outlined,
        'color': Colors.purple,
      },
      {'name': 'Impatience', 'icon': Icons.timer_outlined, 'color': Colors.red},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Trade Journal',
            style: AppTypography.heading.copyWith(
              fontSize: 20.sp,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How did you feel during this trade?',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: emotions.map((e) {
                    bool isSelected = selectedEmotion == e['name'];
                    return GestureDetector(
                      onTap: () => setDialogState(
                        () => selectedEmotion = e['name'] as String,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (e['color'] as Color).withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? (e['color'] as Color)
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              e['icon'] as IconData,
                              size: 16.sp,
                              color: isSelected
                                  ? (e['color'] as Color)
                                  : AppColors.textBody,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              e['name'] as String,
                              style: AppTypography.body.copyWith(
                                fontSize: 12.sp,
                                color: isSelected
                                    ? (e['color'] as Color)
                                    : AppColors.textBody,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Notes (Optional)',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: AppTypography.body.copyWith(color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: 'e.g., Followed plan, entered late...',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textBody.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onSave(selectedEmotion, noteController.text);
                Navigator.pop(context);
              },
              child: Text(
                'SAVE JOURNAL',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
