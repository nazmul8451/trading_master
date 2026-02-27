import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../service/notification_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'notification_list_screen.dart';
import '../plan/goal_plans_library_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../trade/trade_setup_screen.dart';
import '../../service/profile_service.dart';
import '../journal/journal_screen.dart';
import '../../service/wallet_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';
import '../../../core/utils/compounding_calculator.dart';
import '../../service/trade_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  String _userName = "Trader"; // Default or fetched
  List<CompoundingPoint> _historyPoints = [];
  List<CompoundingPoint> _projectionPoints = [];
  double _growthPercentage = 0.0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    _balance = WalletService.balance;
    _userName = ProfileService.name;
    _unreadCount = NotificationService().getUnreadCount();
    _loadChartData();

    GetStorage().listenKey(NotificationService.unreadCountKey, (value) {
      if (mounted) {
        setState(() {
          _unreadCount = value as int? ?? 0;
        });
      }
    });

    GetStorage().listenKey(WalletService.balanceKey, (value) {
      if (mounted) {
        setState(() {
          _balance = (value as num?)?.toDouble() ?? 0.0;
        });
        _loadChartData();
      }
    });

    GetStorage().listenKey(TradeStorageService.storageKey, (value) {
      if (mounted) _loadChartData();
    });

    GetStorage().listenKey(WalletService.historyKey, (value) {
      if (mounted) _loadChartData();
    });
  }

  void _loadChartData() {
    final history = CompoundingCalculator.getHistoricalPoints();
    final projection = CompoundingCalculator.getProjectedPoints(
      2.5,
      7,
    ); // 7 days projection

    setState(() {
      _historyPoints = history;
      _projectionPoints = projection;

      if (history.length > 1) {
        final start = history.first.balance;
        final end = history.last.balance;
        if (start > 0) {
          _growthPercentage = ((end - start) / start) * 100;
        }
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
          physics: const BouncingScrollPhysics(),
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
          child: InkWell(
            onTap: () {
              NotificationService().resetUnreadCount();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationListScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textMain,
                  size: 22.sp,
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.sp,
                        minHeight: 14.sp,
                      ),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Compounding Projection",
              style: AppTypography.subHeading.copyWith(
                fontSize: 16.sp,
                color: AppColors.textMain,
              ),
            ),
            if (_growthPercentage != 0)
              Text(
                "${_growthPercentage >= 0 ? '+' : ''}${_growthPercentage.toStringAsFixed(1)}%",
                style: AppTypography.buttonText.copyWith(
                  fontSize: 12.sp,
                  color: _growthPercentage >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
          ],
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 180.h,
          child: _historyPoints.isEmpty
              ? Center(
                  child: Text(
                    "Not enough data to project",
                    style: AppTypography.body.copyWith(
                      color: AppColors.textBody,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Historical Data Bar
                      LineChartBarData(
                        spots: _historyPoints.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.balance);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Projection Data Bar
                      if (_projectionPoints.length > 1)
                        LineChartBarData(
                          spots: _projectionPoints.asMap().entries.map((e) {
                            // X-offset by history length
                            return FlSpot(
                              (_historyPoints.length - 1 + e.key).toDouble(),
                              e.value.balance,
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary.withOpacity(0.4),
                          barWidth: 2,
                          dashArray: [5, 5],
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                        ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => AppColors.surface,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final isHistory = spot.barIndex == 0;
                            final point = isHistory
                                ? _historyPoints[spot.x.toInt()]
                                : _projectionPoints[spot.x.toInt() -
                                      (_historyPoints.length - 1)];

                            final dateStr = DateFormat(
                              'MMM dd',
                            ).format(point.date);
                            return LineTooltipItem(
                              "$dateStr (${isHistory ? 'Hist' : 'Proj'})\n",
                              AppTypography.body.copyWith(
                                color: AppColors.textBody,
                                fontSize: 10.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: NumberFormat.simpleCurrency().format(
                                    spot.y,
                                  ),
                                  style: AppTypography.buttonText.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend("History", AppColors.primary),
            SizedBox(width: 24.w),
            _buildChartLegend(
              "Projection",
              AppColors.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 10.sp,
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}
