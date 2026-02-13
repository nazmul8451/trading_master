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
  final List<String> _currencies = ['\$', '৳', '€', '£', '¥', '₹'];

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
        title: Text(
          'New Trading Plan',
          style: AppTypography.heading.copyWith(fontSize: 20.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
                  SizedBox(height: 100.h), // Spacing for AppBar
                  AnimatedEntrance(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.rocket_launch,
                            size: 48.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Plan Your Success',
                          style: AppTypography.heading.copyWith(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Define your trading parameters and visualize the power of compounding.',
                          style: AppTypography.body.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textBody.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Inputs
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 200),
                    child: GlassContainer(
                      padding: EdgeInsets.all(24.r),
                      borderRadius: 24.r,
                      color: AppColors.surface.withOpacity(0.4),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      child: Column(
                        children: [
                          _buildFieldContainer(
                            label: 'Starting Capital',
                            child: Row(
                              children: [
                                _buildCurrencyDropdown(),
                                Expanded(
                                  child: TextFormField(
                                    controller: _capitalController,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 24.sp,
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
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 32.h,
                          ),
                          _buildFieldContainer(
                            label: 'Daily Target (%)',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pie_chart,
                                  color: AppColors.accentBlue,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _targetController,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 24.sp,
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
                                Text(
                                  '%',
                                  style: AppTypography.heading.copyWith(
                                    fontSize: 24.sp,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 32.h,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildFieldContainer(
                                  label: 'Duration',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: AppColors.success,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _durationController,
                                          style: AppTypography.heading.copyWith(
                                            fontSize: 24.sp,
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (val) =>
                                              val!.isEmpty ? 'Required' : null,
                                          decoration: _slimmestInputDecoration(
                                            '30',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 2,
                                child: _buildDurationTypeDropdown(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Action Button
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2369FF), Color(0xFF0044D6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2369FF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _calculateAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 22.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Generate Blueprint',
                              style: AppTypography.buttonText.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
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

  Widget _buildFieldContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            fontSize: 10.sp,
            color: AppColors.textBody.withOpacity(0.7),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCurrency,
        dropdownColor: AppColors.surface,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16.sp,
          color: AppColors.textBody,
        ),
        style: AppTypography.heading.copyWith(fontSize: 24.sp),
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
    );
  }

  Widget _buildDurationTypeDropdown() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
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
              Icons.keyboard_arrow_down,
              color: AppColors.textBody,
              size: 20.sp,
            ),
            style: AppTypography.body.copyWith(
              fontSize: 14.sp,
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
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
