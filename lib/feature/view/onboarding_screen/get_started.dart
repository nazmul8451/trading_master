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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w.clamp(20, 32)),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 20.h.clamp(16, 24)),
                        _buildTopBar(),
                        SizedBox(height: 40.h.clamp(32, 48)),
                        _buildFeatureCard(),
                        SizedBox(height: 40.h.clamp(32, 48)),
                        _buildContent(),
                        const Spacer(),
                        SizedBox(height: 40.h.clamp(32, 48)),
                        _buildActions(context),
                        SizedBox(height: 20.h.clamp(16, 24)),
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
        Icon(Icons.shield_outlined, color: AppColors.textBody, size: 20.sp.clamp(18, 24)),
        SizedBox(width: 8.w.clamp(6, 12)),
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
      height: 220.h.clamp(200, 260),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r.clamp(20, 32)),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 80.sp.clamp(70, 100),
            ),
            SizedBox(height: 24.h.clamp(20, 32)),
            Container(
              width: 120.w.clamp(100, 140),
              height: 4.h.clamp(3, 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r.clamp(1, 4)),
              ),
            ),
            SizedBox(height: 12.h.clamp(8, 16)),
            Container(
              width: 80.w.clamp(60, 100),
              height: 4.h.clamp(3, 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.r.clamp(1, 4)),
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
        SizedBox(height: 15.h.clamp(12, 20)),
        Text(
          "Profit is secondary. Discipline is\nprimary.",
          textAlign: TextAlign.center,
          style: AppTypography.subHeading,
        ),
        SizedBox(height: 20.h.clamp(16, 28)),
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
            minimumSize: Size(double.infinity, 56.h.clamp(48, 64)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r.clamp(12, 20)),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Start Discipline Setup", style: AppTypography.buttonText),
              SizedBox(width: 8.w.clamp(6, 12)),
              Icon(Icons.arrow_forward, size: 20.sp.clamp(18, 24)),
            ],
          ),
        ),
        SizedBox(height: 12.h.clamp(8, 16)),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 56.h.clamp(48, 64)),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r.clamp(12, 20)),
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
