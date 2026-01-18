import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../plan/goal_plans_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w.clamp(16, 24).toDouble()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h.clamp(12, 20).toDouble()),
              _buildHeader(),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              _buildBalanceCard(),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              _buildDisciplineStatus(),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              _buildQuickActions(context),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
              _buildCompoundingCurve(),
              SizedBox(height: 24.h.clamp(20, 32).toDouble()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48.sp.clamp(40, 56).toDouble(),
          height: 48.sp.clamp(40, 56).toDouble(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              "AS",
              style: AppTypography.buttonText.copyWith(
                fontSize: 18.sp.clamp(16, 22).toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w.clamp(8, 16).toDouble()),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back",
                style: AppTypography.body.copyWith(
                  fontSize: 12.sp.clamp(10, 14).toDouble(),
                  color: AppColors.textBody,
                ),
              ),
              Text(
                "Alex Sterling",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 16.sp.clamp(14, 18).toDouble(),
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40.sp.clamp(36, 48).toDouble(),
          height: 40.sp.clamp(36, 48).toDouble(),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.textMain,
            size: 22.sp.clamp(18, 26).toDouble(),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r.clamp(16, 24).toDouble()),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r.clamp(16, 24).toDouble()),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CURRENT BALANCE",
                style: AppTypography.body.copyWith(
                  fontSize: 11.sp.clamp(9, 13).toDouble(),
                  color: AppColors.textBody,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w.clamp(6, 12).toDouble(),
                  vertical: 4.h.clamp(2, 6).toDouble(),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r.clamp(4, 8).toDouble()),
                ),
                child: Text(
                  "Day 12 / 30",
                  style: AppTypography.body.copyWith(
                    fontSize: 10.sp.clamp(8, 12).toDouble(),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h.clamp(6, 12).toDouble()),
          Text(
            "\$12,450.00",
            style: TextStyle(
              fontSize: 36.sp.clamp(30, 42).toDouble(),
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 16.h.clamp(12, 20).toDouble()),
          Text(
            "Daily Target Progress",
            style: AppTypography.body.copyWith(
              fontSize: 12.sp.clamp(10, 14).toDouble(),
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 8.h.clamp(6, 12).toDouble()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$325 / \$500",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 14.sp.clamp(12, 16).toDouble(),
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h.clamp(6, 12).toDouble()),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r.clamp(6, 12).toDouble()),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 8.h.clamp(6, 10).toDouble(),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 8.h.clamp(6, 12).toDouble()),
          Text(
            "65% of compounding target reached today",
            style: AppTypography.body.copyWith(
              fontSize: 11.sp.clamp(9, 13).toDouble(),
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 16.h.clamp(12, 20).toDouble()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textMain,
                minimumSize: Size(double.infinity, 48.h.clamp(42, 54).toDouble()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                ),
                elevation: 0,
              ),
              child: Text(
                "View Detailed Plan",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 14.sp.clamp(12, 16).toDouble(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Discipline Status",
          style: AppTypography.subHeading.copyWith(
            fontSize: 18.sp.clamp(16, 22).toDouble(),
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h.clamp(8, 16).toDouble()),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40.sp.clamp(36, 48).toDouble(),
                height: 40.sp.clamp(36, 48).toDouble(),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24.sp.clamp(20, 28).toDouble(),
                ),
              ),
              SizedBox(width: 12.w.clamp(8, 16).toDouble()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Within Plan",
                      style: AppTypography.buttonText.copyWith(
                        fontSize: 14.sp.clamp(12, 16).toDouble(),
                        color: AppColors.textMain,
                      ),
                    ),
                    SizedBox(height: 2.h.clamp(1, 4).toDouble()),
                    Text(
                      "Risk parameters are optimal. No plan violations detected.",
                      style: AppTypography.body.copyWith(
                        fontSize: 11.sp.clamp(9, 13).toDouble(),
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textBody,
                size: 20.sp.clamp(18, 24).toDouble(),
              ),
            ],
          ),
        ),
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
            fontSize: 18.sp.clamp(16, 22).toDouble(),
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h.clamp(8, 16).toDouble()),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12.h.clamp(8, 16).toDouble(),
          crossAxisSpacing: 12.w.clamp(8, 16).toDouble(),
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(
              icon: Icons.add_chart,
              label: "Add Trade",
              color: const Color(0xFF3B82F6),
              onTap: () {},
            ),
            _buildActionCard(
              icon: Icons.track_changes,
              label: "Goal Plan",
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoalPlansLibraryScreen()),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.menu_book,
              label: "Journal",
              color: const Color(0xFFF59E0B),
              onTap: () {},
            ),
            _buildActionCard(
              icon: Icons.analytics,
              label: "Analytics",
              color: const Color(0xFFEF4444),
              onTap: () {},
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.sp.clamp(40, 56).toDouble(),
                height: 48.sp.clamp(40, 56).toDouble(),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24.sp.clamp(20, 28).toDouble(),
                ),
              ),
              SizedBox(height: 8.h.clamp(6, 12).toDouble()),
              Text(
                label,
                style: AppTypography.buttonText.copyWith(
                  fontSize: 13.sp.clamp(11, 15).toDouble(),
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompoundingCurve() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Compounding Curve",
          style: AppTypography.subHeading.copyWith(
            fontSize: 18.sp.clamp(16, 22).toDouble(),
            color: AppColors.textMain,
          ),
        ),
        SizedBox(height: 12.h.clamp(8, 16).toDouble()),
        Container(
          width: double.infinity,
          height: 200.h.clamp(180, 240).toDouble(),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r.clamp(12, 20).toDouble()),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r.clamp(12, 20).toDouble()),
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: _CompoundingCurvePainter(),
                ),
              ),
              Positioned(
                bottom: 12.h.clamp(8, 16).toDouble(),
                left: 16.w.clamp(12, 20).toDouble(),
                child: Text(
                  "PROJECTION: \$25,000.00 BY DAY 30",
                  style: AppTypography.body.copyWith(
                    fontSize: 10.sp.clamp(8, 12).toDouble(),
                    color: AppColors.textBody,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Positioned(
                bottom: 12.h.clamp(8, 16).toDouble(),
                right: 16.w.clamp(12, 20).toDouble(),
                child: Text(
                  "+12.4%",
                  style: AppTypography.buttonText.copyWith(
                    fontSize: 12.sp.clamp(10, 14).toDouble(),
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
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    final linePath = Path();

    path.moveTo(0, size.height);
    linePath.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i += 1) {
      final x = i;
      final progress = i / size.width;
      final y = size.height * 0.7 * (1 - progress * 0.8);
      
      linePath.lineTo(x, y);
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);

    final gridPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
