import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/risk_calculation_utils.dart';
import '../../service/ad_service.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../service/wallet_service.dart';

class RiskCalculatorScreen extends StatefulWidget {
  const RiskCalculatorScreen({super.key});

  @override
  State<RiskCalculatorScreen> createState() => _RiskCalculatorScreenState();
}

class _RiskCalculatorScreenState extends State<RiskCalculatorScreen> {
  final _balanceController = TextEditingController(
    text: WalletService.balance.toString(),
  );
  final _riskPercentController = TextEditingController(text: "1.0");
  final _stopLossController = TextEditingController();

  AssetType _selectedAsset = AssetType.forex;
  RiskResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final balance = double.tryParse(_balanceController.text) ?? 0;
    final riskPercent = double.tryParse(_riskPercentController.text) ?? 0;
    final stopLoss = double.tryParse(_stopLossController.text) ?? 0;

    setState(() {
      _result = RiskCalculationUtils.calculatePositionSize(
        balance: balance,
        riskPercentage: riskPercent,
        stopLoss: stopLoss,
        assetType: _selectedAsset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Risk Calculator"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AdService().showInterstitialAd();
            Navigator.pop(context);
          },
        ),
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputSection(),
              SizedBox(height: 24.h),
              if (_result != null) _buildResultSection(),
              SizedBox(height: 24.h),
              _buildRiskEducation(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      borderRadius: 20.r,
      color: Colors.white.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Account Balance (\$)", _balanceController),
          SizedBox(height: 16.h),
          _buildTextField("Risk Percentage (%)", _riskPercentController),
          SizedBox(height: 16.h),
          _buildTextField(
            "Stop Loss Distance",
            _stopLossController,
            hint: "Pips/Points/Price",
          ),
          SizedBox(height: 20.h),
          Text(
            "Asset Type",
            style: AppTypography.label.copyWith(color: AppColors.textBody),
          ),
          SizedBox(height: 8.h),
          _buildAssetSelector(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.textBody),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.primary,
          style: TextStyle(color: AppColors.textMain, fontSize: 16.sp),
          onChanged: (_) => _calculate(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textBody.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetSelector() {
    return Row(
      children: AssetType.values.map((type) {
        bool isSelected = _selectedAsset == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedAsset = type);
              _calculate();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  type.name.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textBody,
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultSection() {
    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      borderRadius: 24.r,
      color: AppColors.primary.withOpacity(0.1),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      child: Column(
        children: [
          Text(
            "RECOMMENDED POSITION",
            style: AppTypography.label.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "${_result!.positionSize.toStringAsFixed(2)} ${_result!.unit}",
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Total Risk: \$${_result!.riskAmount.toStringAsFixed(2)}",
            style: AppTypography.body.copyWith(color: AppColors.textBody),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskEducation() {
    return GlassContainer(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      borderRadius: 16.r,
      color: Colors.white.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "Why Position Sizing Matters?",
                style: AppTypography.buttonText,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "Successful trading is not just about choosing direction. It's about surviving strings of losses. Proper risk management ensures that no single trade can wipe out your account.",
            style: AppTypography.body.copyWith(
              fontSize: 12.sp,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
