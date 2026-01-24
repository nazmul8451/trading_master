import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../controller/trade_controller.dart';
import '../../model/trade_plan_model.dart';
import 'trade_plan_screen.dart';

class TradeSetupScreen extends StatefulWidget {
  const TradeSetupScreen({super.key});

  @override
  State<TradeSetupScreen> createState() => _TradeSetupScreenState();
}

class _TradeSetupScreenState extends State<TradeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController(text: '100');
  final _targetProfitController = TextEditingController(text: '10');
  final _stopLossController = TextEditingController(text: '10');
  final _payoutController = TextEditingController(text: '82');
  String _selectedCurrency = '\$';
  final List<String> _currencies = ['\$', '৳', '€', '£', '¥', '₹'];

  @override
  void dispose() {
    _balanceController.dispose();
    _targetProfitController.dispose();
    _stopLossController.dispose();
    _payoutController.dispose();
    super.dispose();
  }

  void _generatePlan() {
    if (_formKey.currentState!.validate()) {
      final balance = double.parse(_balanceController.text);
      final target = double.parse(_targetProfitController.text);
      final stopLoss = double.parse(_stopLossController.text);
      final payout = double.parse(_payoutController.text);

      final entries = TradeController.generateInitialPlan(
        totalTarget: target,
        payoutPercentage: payout,
      );
      
      final plan = TradePlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        balance: balance,
        targetProfit: target,
        stopLossLimit: stopLoss,
        payoutPercentage: payout,
        currency: _selectedCurrency,
        date: DateTime.now(),
        entries: entries,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TradePlanScreen(plan: plan),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textMain, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Capital-Based Plan Setup',
          style: AppTypography.subHeading.copyWith(color: AppColors.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your daily parameters. The app will use your current capital to calculate precise trade sizes for optimal risk management.',
                style: AppTypography.body.copyWith(color: AppColors.textBody),
              ),
              SizedBox(height: 32.h),
              _buildInputCard(
                label: 'CURRENT BALANCE ($_selectedCurrency)',
                hint: '100.00',
                controller: _balanceController,
                description: 'Total available trading capital as of today.',
                prefix: _buildCurrencyDropdown(),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      label: 'TARGET PROFIT',
                      hint: '10.00',
                      controller: _targetProfitController,
                      description: 'Goal for this session.',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildInputCard(
                      label: 'STOP LOSS',
                      hint: '10.00',
                      controller: _stopLossController,
                      description: 'Max risk limit.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildInputCard(
                label: 'PAYOUT PERCENTAGE (%)',
                hint: '82',
                controller: _payoutController,
                description: 'Broker payout ratio (e.g., 82 for 82%).',
                isPercentage: true,
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'The app will calculate your investment per trade based on these values to ensure your capital is protected.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textMain,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _generatePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Generate Daily Trade Plan',
                        style: AppTypography.buttonText.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.auto_awesome, color: AppColors.textMain, size: 20.sp),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  'STRICT RISK ADHERENCE ENABLED',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody.withOpacity(0.5),
                    fontSize: 10.sp,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String description,
    Widget? prefix,
    bool isPercentage = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                  color: AppColors.textBody,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (prefix != null) ...[
                    prefix,
                    SizedBox(width: 8.w),
                  ] else if (!isPercentage) ...[
                    Text(
                      _selectedCurrency,
                      style: AppTypography.heading.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.textBody.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTypography.heading.copyWith(
                        fontSize: 20.sp,
                        color: AppColors.textMain,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTypography.heading.copyWith(
                          fontSize: 20.sp,
                          color: AppColors.textBody.withOpacity(0.2),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        suffixText: isPercentage ? '%' : null,
                        suffixStyle: AppTypography.heading.copyWith(
                          fontSize: 18.sp,
                          color: AppColors.textBody.withOpacity(0.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            description,
            style: AppTypography.body.copyWith(
              color: AppColors.textBody.withOpacity(0.6),
              fontSize: 10.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColors.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          icon: Icon(Icons.keyboard_arrow_down, size: 16.sp, color: AppColors.textBody),
          items: _currencies.map((String currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
                style: AppTypography.heading.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.textMain,
                ),
              ),
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
}
