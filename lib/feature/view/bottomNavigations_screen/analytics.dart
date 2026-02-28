import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/trade_plan_model.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import '../../service/trade_storage_service.dart';
import '../../../core/widgets/banner_ad_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<TradePlanModel> _sessions = [];
  bool _isLoading = true;
  String _selectedTimeframe = 'All'; // 'Week', 'Month', 'All'

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen for storage changes to auto-refresh
    GetStorage().listenKey(TradeStorageService.storageKey, (value) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final sessions = TradeStorageService().getAllTradeSessions();
    sessions.sort((a, b) => a.date.compareTo(b.date));
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Analytics', style: AppTypography.subHeading),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64.sp,
                color: AppColors.textBody.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                'No trade data available yet.\nStart a session to see analytics!',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textBody),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Performance Hub', style: AppTypography.subHeading),
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 60.h,
          left: 16.w,
          right: 16.w,
          bottom: 30.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainStats(stats),
            SizedBox(height: 24.h),
            Text(
              'Profit Curve',
              style: AppTypography.subHeading.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            _buildTimeframeSelector(),
            SizedBox(height: 16.h),
            _buildProfitChart(),
            SizedBox(height: 24.h),
            const BannerAdWidget(),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildRatioCard(
                    'Win Rate',
                    '${stats['winRate'].toStringAsFixed(1)}%',
                    AppColors.success,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildRatioCard(
                    'RR Ratio',
                    '1:${stats['rrRatio'].toStringAsFixed(2)}',
                    AppColors.accentBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildDetailsGrid(stats),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    int totalTrades = 0;
    int wins = 0;
    double totalProfitAmount = 0;
    double totalLossAmount = 0;

    for (var session in _sessions) {
      for (var entry in session.entries) {
        if (entry.status == 'win') {
          totalTrades++;
          wins++;
          totalProfitAmount += entry.potentialProfit;
        } else if (entry.status == 'loss') {
          totalTrades++;
          totalLossAmount += entry.investAmount;
        }
      }
    }

    double winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : 0;
    double avgWin = wins > 0 ? totalProfitAmount / wins : 0;
    int losses = totalTrades - wins;
    double avgLoss = losses > 0 ? totalLossAmount / losses : 0;
    double rrRatio = avgLoss > 0 ? avgWin / avgLoss : 0;

    return {
      'totalTrades': totalTrades,
      'wins': wins,
      'losses': totalTrades - wins,
      'winRate': winRate,
      'rrRatio': rrRatio,
      'totalProfit': totalProfitAmount - totalLossAmount,
      'avgWin': avgWin,
      'avgLoss': avgLoss,
    };
  }

  Widget _buildMainStats(Map<String, dynamic> stats) {
    bool isProfit = stats['totalProfit'] >= 0;
    return _GlassCard(
      child: Column(
        children: [
          Text(
            'Total Net Profit',
            style: AppTypography.body.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 8.h),
          Text(
            '${isProfit ? '+' : ''}${stats['totalProfit'].toStringAsFixed(2)}',
            style: AppTypography.heading.copyWith(
              fontSize: 32.sp,
              color: isProfit ? AppColors.success : AppColors.error,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat('Trades', stats['totalTrades'].toString()),
              _buildSmallStat(
                'Wins',
                stats['wins'].toString(),
                color: AppColors.success,
              ),
              _buildSmallStat(
                'Losses',
                stats['losses'].toString(),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            fontSize: 12.sp,
            color: AppColors.textBody,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.subHeading.copyWith(
            fontSize: 16.sp,
            color: color ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildRatioCard(String label, String value, Color color) {
    return _GlassCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 12.sp,
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTypography.heading.copyWith(
              fontSize: 20.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                'Avg. Win',
                '+${stats['avgWin'].toStringAsFixed(2)}',
                AppColors.success,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildDetailItem(
                'Avg. Loss',
                '-${stats['avgLoss'].toStringAsFixed(2)}',
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 11.sp,
              color: AppColors.textBody,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.subHeading.copyWith(
              fontSize: 15.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeframeBtn('1W', 'Week'),
          _buildTimeframeBtn('1M', 'Month'),
          _buildTimeframeBtn('All', 'All'),
        ],
      ),
    );
  }

  Widget _buildTimeframeBtn(String label, String value) {
    bool isSelected = _selectedTimeframe == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.buttonText.copyWith(
            fontSize: 12.sp,
            color: isSelected ? AppColors.primary : AppColors.textBody,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProfitChart() {
    // Filter sessions based on timeframe
    List<TradePlanModel> filteredSessions = [];
    if (_selectedTimeframe == 'All') {
      filteredSessions = List.from(_sessions);
    } else {
      final now = DateTime.now();
      final days = _selectedTimeframe == 'Week' ? 7 : 30;
      final cutoff = now.subtract(Duration(days: days));
      filteredSessions = _sessions
          .where((s) => s.date.isAfter(cutoff))
          .toList();
    }

    if (filteredSessions.isEmpty) {
      return Container(
        height: 250.h,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Text(
          "No data for this period",
          style: AppTypography.body.copyWith(color: AppColors.textBody),
        ),
      );
    }

    List<FlSpot> spots = [];
    double runningProfit = 0;

    for (int i = 0; i < filteredSessions.length; i++) {
      var session = filteredSessions[i];
      double sessionProfit = 0;
      for (var entry in session.entries) {
        if (entry.status == 'win') sessionProfit += entry.potentialProfit;
        if (entry.status == 'loss') sessionProfit -= entry.investAmount;
      }
      runningProfit += sessionProfit;
      spots.add(FlSpot(i.toDouble(), runningProfit));
    }

    return Container(
      height: 250.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8.w, 24.h, 24.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border.withOpacity(0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < filteredSessions.length) {
                    if (filteredSessions.length > 5 &&
                        index % (filteredSessions.length ~/ 5) != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat(
                          'MM/dd',
                        ).format(filteredSessions[index].date),
                        style: AppTypography.body.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textBody,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compactSimpleCurrency().format(value),
                    style: AppTypography.body.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.textBody,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              shadow: const Shadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.background,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  final date = DateFormat(
                    'MMM dd\nhh:mm a',
                  ).format(filteredSessions[index].date);
                  return LineTooltipItem(
                    '$date\n',
                    TextStyle(
                      color: AppColors.textBody,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                    children: [
                      TextSpan(
                        text: NumberFormat.simpleCurrency().format(
                          touchedSpot.y,
                        ),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
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
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.01),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
