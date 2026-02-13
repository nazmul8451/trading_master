import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../plan/goal_plans_library_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../trade/trade_setup_screen.dart';
import '../journal/journal_screen.dart';
import '../../service/wallet_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  String _userName = "Rimon islam"; // Default or fetched

  @override
  void initState() {
    super.initState();
    _balance = WalletService.balance;
    GetStorage().listenKey('available_balance', (value) {
      if (mounted) {
        setState(() {
          _balance = (value as num?)?.toDouble() ?? 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w.clamp(16, 24).toDouble(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              AnimatedEntrance(child: _buildHeader(context)),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 200),
                child: GlassContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  borderRadius: 24.r,
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  child: _buildBalanceCardContent(),
                ),
              ),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 300),
                child: GlassContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  borderRadius: 24.r,
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  child: _buildDisciplineContent(),
                ),
              ),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActions(context),
              ),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 500),
                child: GlassContainer(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  borderRadius: 24.r,
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  child: _buildCompoundingCurveContent(),
                ),
              ),
              SizedBox(height: 100.h), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => DashboardScreen.of(context)?.toggleDrawer(),
          child: Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back",
                style: AppTypography.body.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textBody,
                ),
              ),
              Text(
                _userName,
                style: AppTypography.buttonText.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.textMain,
            size: 22.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CURRENT BALANCE",
              style: AppTypography.label.copyWith(
                fontSize: 11.sp,
                color: AppColors.textBody,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                "Active",
                style: AppTypography.label.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          NumberFormat.simpleCurrency().format(_balance),
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "Quick Stats",
          style: AppTypography.body.copyWith(
            fontSize: 12.sp,
            color: AppColors.textBody,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: 0.65, // Placeholder for actual progress
            minHeight: 8.h,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalPlansLibraryScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textMain,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "View Plans",
                  style: AppTypography.buttonText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward, size: 16.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineContent() {
    return Row(
      children: [
        Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Health Check",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "System optimal. No risk violations.",
                style: AppTypography.body.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: AppColors.textBody, size: 20.sp),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: AppTypography.subHeading.copyWith(
            fontSize: 18.sp,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(
              icon: Icons.rocket_launch,
              label: "New Plan",
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TradeSetupScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.track_changes,
              label: "Goal Plans",
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalPlansLibraryScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.edit_note,
              label: "Journal",
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JournalScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.analytics,
              label: "Analytics",
              color: const Color(0xFFEF4444),
              onTap: () {
                DashboardScreen.of(context)?.changePageIndex(1);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16.r,
      color: Colors.white.withOpacity(0.03),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.sp,
                height: 48.sp,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTypography.buttonText.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompoundingCurveContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Compounding Projection",
          style: AppTypography.subHeading.copyWith(
            fontSize: 16.sp,
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 150.h,
          child: Stack(
            children: [
              // Simple curve placeholder
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: _CompoundingCurvePainter(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  "+12.4%",
                  style: AppTypography.buttonText.copyWith(
                    fontSize: 12.sp,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompoundingCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final linePath = Path();

    // Smoother bezier curve
    path.moveTo(0, size.height);
    linePath.moveTo(0, size.height * 0.8);

    path.lineTo(0, size.height * 0.8);

    linePath.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.4,
      size.width,
      size.height * 0.2,
    );

    path.addPath(linePath, Offset.zero);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
