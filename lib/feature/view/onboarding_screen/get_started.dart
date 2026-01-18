import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w.clamp(20, 32).toDouble()),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h.clamp(16, 24).toDouble()),
                        _buildTopBar(),
                        SizedBox(height: 32.h.clamp(24, 40).toDouble()),
                        _buildFeatureCard(),
                        SizedBox(height: 32.h.clamp(24, 40).toDouble()),
                        _buildContent(),
                        const Spacer(),
                        SizedBox(height: 32.h.clamp(24, 40).toDouble()),
                        _buildActions(context),
                        SizedBox(height: 20.h.clamp(16, 24).toDouble()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.textBody, size: 20.sp.clamp(18, 24).toDouble()),
        SizedBox(width: 8.w.clamp(6, 12).toDouble()),
        Text(
          "SYSTEM PROTOCOL",
          style: AppTypography.protocolText,
        ),
      ],
    );
  }

  Widget _buildFeatureCard() {
    return Container(
      width: double.infinity,
      height: 200.h.clamp(180, 240).toDouble(),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r.clamp(20, 32).toDouble()),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 70.sp.clamp(60, 90).toDouble(),
            ),
            SizedBox(height: 20.h.clamp(16, 28).toDouble()),
            Container(
              width: 110.w.clamp(90, 130).toDouble(),
              height: 4.h.clamp(3, 6).toDouble(),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r.clamp(1, 4).toDouble()),
              ),
            ),
            SizedBox(height: 10.h.clamp(6, 14).toDouble()),
            Container(
              width: 70.w.clamp(50, 90).toDouble(),
              height: 4.h.clamp(3, 6).toDouble(),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.r.clamp(1, 4).toDouble()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Text(
          "Trade to Survive\nFirst",
          textAlign: TextAlign.center,
          style: AppTypography.heading,
        ),
        SizedBox(height: 12.h.clamp(10, 18).toDouble()),
        Text(
          "Profit is secondary. Discipline is\nprimary.",
          textAlign: TextAlign.center,
          style: AppTypography.subHeading,
        ),
        SizedBox(height: 16.h.clamp(12, 24).toDouble()),
        Text(
          "This system is designed for\ncompounding wealth through strict risk\nmanagement, not chasing market noise.\nControl your emotions, master your\nedge.",
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.protocolConfirmation);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textMain,
            minimumSize: Size(double.infinity, 54.h.clamp(46, 60).toDouble()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Start Discipline Setup", style: AppTypography.buttonText),
              SizedBox(width: 8.w.clamp(6, 12).toDouble()),
              Icon(Icons.arrow_forward, size: 20.sp.clamp(18, 24).toDouble()),
            ],
          ),
        ),
        SizedBox(height: 12.h.clamp(8, 16).toDouble()),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 54.h.clamp(46, 60).toDouble()),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
            ),
          ),
          child: Text(
            "Review Our Philosophy",
            style: AppTypography.buttonText.copyWith(color: AppColors.textBody),
          ),
        ),
      ],
    );
  }
}
