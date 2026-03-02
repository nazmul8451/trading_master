import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/premium_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/animated_entrance.dart';

class CompoundCalculatorScreen extends StatefulWidget {
  const CompoundCalculatorScreen({super.key});

  @override
  State<CompoundCalculatorScreen> createState() =>
      _CompoundCalculatorScreenState();
}

class _CompoundCalculatorScreenState extends State<CompoundCalculatorScreen> {
  final _initialCapitalController = TextEditingController();
  final _dailyProfitController = TextEditingController();
  final _durationController = TextEditingController();

  double _totalProfit = 0;
  double _finalBalance = 0;
  List<Map<String, dynamic>> _dailyBreakdown = [];
  bool _isCalculated = false;

  @override
  void dispose() {
    _initialCapitalController.dispose();
    _dailyProfitController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    double initial = double.tryParse(_initialCapitalController.text) ?? 0;
    double dailyRate =
        (double.tryParse(_dailyProfitController.text) ?? 0) / 100;
    int days = int.tryParse(_durationController.text) ?? 0;

    if (initial <= 0 || dailyRate <= 0 || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    if (days > 365) days = 365;

    double currentBalance = initial;
    List<Map<String, dynamic>> breakdown = [];

    for (int i = 1; i <= days; i++) {
      double profit = currentBalance * dailyRate;
      currentBalance += profit;
      breakdown.add({'day': i, 'profit': profit, 'balance': currentBalance});
    }

    setState(() {
      _finalBalance = currentBalance;
      _totalProfit = _finalBalance - initial;
      _dailyBreakdown = breakdown;
      _isCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Growth Calculator',
          style: AppTypography.subHeading.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(),
                if (_isCalculated) ...[
                  SizedBox(height: 32.h),
                  _buildSummaryCard(),
                  SizedBox(height: 32.h),
                  _buildBreakdownSection(),
                ] else ...[
                  SizedBox(height: 60.h),
                  _buildEmptyState(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedEntrance(
        delay: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calculate_outlined,
                size: 64.sp,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Ready to Grow?',
              style: AppTypography.subHeading.copyWith(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter your targets above to see\nyour portfolio projection.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return AnimatedEntrance(
      offset: const Offset(0.0, -0.1),
      child: GlassContainer(
        padding: EdgeInsets.all(20.r),
        borderRadius: 24.r,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        child: Column(
          children: [
            _buildInputField(
              label: 'Initial Capital',
              hint: 'e.g. 100',
              suffix: '\$',
              controller: _initialCapitalController,
              icon: Icons.account_balance_wallet_outlined,
            ),
            SizedBox(height: 16.h),
            _buildInputField(
              label: 'Average Daily Profit',
              hint: 'e.g. 3',
              suffix: '%',
              controller: _dailyProfitController,
              icon: Icons.trending_up_rounded,
            ),
            SizedBox(height: 16.h),
            _buildInputField(
              label: 'Trading Duration',
              hint: 'e.g. 30',
              suffix: 'Days',
              controller: _durationController,
              icon: Icons.calendar_month_outlined,
            ),
            SizedBox(height: 24.h),
            InkWell(
              onTap: _calculate,
              child: Container(
                width: double.infinity,
                height: 54.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
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
                    _isCalculated ? 'Recalculate Growth' : 'Calculate Growth',
                    style: AppTypography.buttonText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13.sp,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTypography.body.copyWith(
            color: Colors.white,
            fontSize: 15.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(color: Colors.white24),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Center(
                widthFactor: 1,
                child: Text(
                  suffix,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    double initial = double.tryParse(_initialCapitalController.text) ?? 1;
    double growthPercent = ((_finalBalance / initial) - 1) * 100;

    return AnimatedEntrance(
      delay: const Duration(milliseconds: 100),
      child: GlassContainer(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: 24.r,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        child: Column(
          children: [
            Text(
              'PROJECTED FINAL BALANCE',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '\$${_finalBalance.toStringAsFixed(2)}',
              style: AppTypography.heading.copyWith(
                fontSize: 34.sp,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Profit',
                      '+\$${_totalProfit.toStringAsFixed(2)}',
                      Colors.greenAccent,
                      Icons.arrow_upward_rounded,
                    ),
                  ),
                  Container(width: 1, height: 30.h, color: Colors.white10),
                  Expanded(
                    child: _buildStatItem(
                      'Account Growth',
                      '${growthPercent.toStringAsFixed(0)}%',
                      AppColors.secondary,
                      Icons.speed_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white38),
            SizedBox(width: 4.w),
            Text(
              label.toUpperCase(),
              style: AppTypography.caption.copyWith(
                fontSize: 10.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: AppTypography.subHeading.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection() {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Projections',
                style: AppTypography.subHeading.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${_dailyBreakdown.length} Days',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _dailyBreakdown.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final day = _dailyBreakdown[index];
              return GlassContainer(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                borderRadius: 16.r,
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          '${day['day']}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+\$${day['profit'].toStringAsFixed(2)}',
                            style: AppTypography.body.copyWith(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Balance: \$${day['balance'].toStringAsFixed(2)}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.greenAccent.withOpacity(0.3),
                      size: 18.sp,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
