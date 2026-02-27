import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/trade_plan_model.dart';
import '../../controller/trade_controller.dart';
import 'goal_sheet_screen.dart';
import '../../service/trade_storage_service.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _capitalController = TextEditingController();
  final _targetController = TextEditingController();
  final _durationController = TextEditingController();
  String _durationType = 'Days';
  String _selectedCurrency = '\$';
  final List<String> _currencies = ['\$', 'BDT', '€', '£', '¥', '₹'];

  @override
  void dispose() {
    _capitalController.dispose();
    _targetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _calculateAndNavigate() async {
    if (_formKey.currentState!.validate()) {
      final startCapital = double.parse(_capitalController.text);
      final targetPercent = double.parse(_targetController.text);
      final duration = int.parse(_durationController.text);

      final entries = TradeController.calculateCompoundingPlan(
        startCapital: startCapital,
        targetPercent: targetPercent,
        duration: duration,
      );

      final plan = TradePlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        balance: startCapital,
        targetProfit: targetPercent,
        stopLossLimit: 0,
        payoutPercentage: 82,
        currency: _selectedCurrency,
        durationType: _durationType,
        date: DateTime.now(),
        entries: entries,
      );

      await TradeStorageService().saveTradeSession(plan);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoalSheetScreen(plan: plan)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          'New Trading Plan',
          style: AppTypography.heading.copyWith(fontSize: 20.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w.clamp(20, 32).toDouble(),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.h), // Spacing for AppBar
                  AnimatedEntrance(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_graph_rounded,
                            size: 36.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Plan Your Success',
                          style: AppTypography.heading.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'Define your trading parameters and visualize the power of compounding.',
                            style: AppTypography.body.copyWith(
                              fontSize: 15.sp,
                              color: AppColors.textBody.withOpacity(0.7),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Inputs
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 200),
                    child: GlassContainer(
                      padding: EdgeInsets.all(20.r),
                      borderRadius: 32.r,
                      color: AppColors.surface.withOpacity(0.3),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      child: Column(
                        children: [
                          _buildFieldContainer(
                            label: 'Starting Capital',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.primary,
                            child: Row(
                              children: [
                                _buildCurrencyDropdown(),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _capitalController,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (val) =>
                                        val!.isEmpty ? 'Required' : null,
                                    decoration: _slimmestInputDecoration(
                                      '1000',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCustomDivider(),
                          _buildFieldContainer(
                            label: 'Daily Target Profit',
                            icon: Icons.trending_up_rounded,
                            iconColor: AppColors.success,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _targetController,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (val) =>
                                        val!.isEmpty ? 'Required' : null,
                                    decoration: _slimmestInputDecoration('2.5'),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    '%',
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 20.sp,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCustomDivider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildFieldContainer(
                                  label: 'Growth Period',
                                  icon: Icons.calendar_month_outlined,
                                  iconColor: AppColors.accentBlue,
                                  child: TextFormField(
                                    controller: _durationController,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (val) =>
                                        val!.isEmpty ? 'Required' : null,
                                    decoration: _slimmestInputDecoration('30'),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 26.h),
                                  child: _buildDurationTypeDropdown(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Action Button
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _calculateAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Generate Blueprint',
                              style: AppTypography.buttonText.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(Icons.auto_awesome_rounded, size: 22.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _slimmestInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.heading.copyWith(
        fontSize: 24.sp,
        color: AppColors.textBody.withOpacity(0.2),
      ),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isDense: true,
    );
  }

  Widget _buildFieldContainer({
    required String label,
    required Widget child,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: iconColor.withOpacity(0.8)),
            SizedBox(width: 8.w),
            Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 11.sp,
                color: AppColors.textBody.withOpacity(0.6),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildCustomDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.sp,
            color: AppColors.textBody,
          ),
          style: AppTypography.heading.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          items: _currencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(currency),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCurrency = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDurationTypeDropdown() {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _durationType,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            icon: Icon(
              Icons.unfold_more_rounded,
              color: AppColors.textBody.withOpacity(0.5),
              size: 20.sp,
            ),
            style: AppTypography.body.copyWith(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            items: [
              'Days',
              'Weeks',
              'Months',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _durationType = val!),
          ),
        ),
      ),
    );
  }
}
