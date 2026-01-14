import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class ProtocolConfirmationScreen extends StatefulWidget {
  const ProtocolConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<ProtocolConfirmationScreen> createState() => _ProtocolConfirmationScreenState();
}

class _ProtocolConfirmationScreenState extends State<ProtocolConfirmationScreen> {
  final List<bool> _checkedItems = [false, false, false];
  final List<String> _rules = [
    "I will respect daily loss",
    "I will stop after target",
    "I will not revenge trade",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textMain, size: 24.sp.clamp(20, 28)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Core Rules Acceptance",
          style: AppTypography.body.copyWith(
            color: AppColors.textBody,
            fontSize: 14.sp.clamp(12, 16),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.code, color: AppColors.textBody, size: 20.sp.clamp(18, 24)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w.clamp(20, 32)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h.clamp(16, 24)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r.clamp(6, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r.clamp(8, 16)),
                    ),
                    child: Icon(Icons.shield_rounded, color: AppColors.primary, size: 24.sp.clamp(20, 28)),
                  ),
                  SizedBox(width: 16.w.clamp(12, 20)),
                  Expanded(
                    child: Text(
                      "Protocol Confirmation",
                      style: AppTypography.subHeading.copyWith(color: AppColors.textMain),
                    ),
                  ),
                  Text(
                    "Step 1/1",
                    style: AppTypography.body.copyWith(fontSize: 14.sp.clamp(12, 16)),
                  ),
                ],
              ),
              SizedBox(height: 48.h.clamp(40, 56)),
              Text(
                "Commit to your\nDiscipline",
                style: AppTypography.heading,
              ),
              SizedBox(height: 24.h.clamp(20, 32)),
              Text(
                "Discipline is the bridge between goals and accomplishment. Acknowledge your limits to proceed with the compounding plan.",
                style: AppTypography.body,
              ),
              SizedBox(height: 40.h.clamp(32, 48)),
              ...List.generate(_rules.length, (index) => _buildCheckItem(index)),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textBody, size: 16.sp.clamp(14, 20)),
                  SizedBox(width: 8.w.clamp(6, 12)),
                  Expanded(
                    child: Text(
                      "Breaking these rules violates your active compounding plan.",
                      style: AppTypography.body.copyWith(fontSize: 12.sp.clamp(10, 14)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h.clamp(20, 32)),
              ElevatedButton(
                onPressed: _checkedItems.contains(false) ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textMain,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  disabledForegroundColor: AppColors.textMain.withOpacity(0.5),
                  minimumSize: Size(double.infinity, 56.h.clamp(48, 64)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r.clamp(12, 20)),
                  ),
                  elevation: 0,
                ),
                child: Text("I Accept Discipline", style: AppTypography.buttonText),
              ),
              SizedBox(height: 20.h.clamp(16, 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checkedItems[index] = !_checkedItems[index];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h.clamp(12, 20)),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w.clamp(16, 24),
          vertical: 16.h.clamp(12, 20),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r.clamp(12, 20)),
          border: Border.all(
            color: _checkedItems[index] ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _rules[index],
                style: AppTypography.buttonText.copyWith(
                  color: _checkedItems[index] ? AppColors.textMain : AppColors.textBody,
                ),
              ),
            ),
            Container(
              width: 24.sp.clamp(20, 28),
              height: 24.sp.clamp(20, 28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _checkedItems[index] ? AppColors.primary : AppColors.textBody.withOpacity(0.5),
                  width: 2,
                ),
                color: _checkedItems[index] ? AppColors.primary : Colors.transparent,
              ),
              child: _checkedItems[index]
                  ? Icon(Icons.check, color: AppColors.textMain, size: 16.sp.clamp(14, 20))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
