import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../model/plan_model.dart';
import 'goal_sheet_screen.dart';

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

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      final plan = PlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startCapital: double.parse(_capitalController.text),
        targetPercent: double.parse(_targetController.text),
        duration: int.parse(_durationController.text),
        durationType: _durationType,
        currency: _selectedCurrency,
        startDate: DateTime.now(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalSheetScreen(plan: plan),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Trading Plan'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w.clamp(16, 24).toDouble()),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h.clamp(16, 24).toDouble()),
                Text(
                  'Plan Your Success',
                  style: AppTypography.heading.copyWith(
                    fontSize: 24.sp.clamp(20, 28).toDouble(),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h.clamp(4, 12).toDouble()),
                Text(
                  'Define your trading parameters and start compounding your wealth.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h.clamp(24, 40).toDouble()),
                _buildTextField(
                  controller: _capitalController,
                  label: 'Starting Capital',
                  hint: 'e.g., 1000',
                  prefixIcon: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCurrency,
                        dropdownColor: AppColors.surface,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.keyboard_arrow_down, size: 16.sp, color: AppColors.textBody),
                        items: _currencies.map((String currency) {
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(
                              currency,
                              style: AppTypography.buttonText.copyWith(
                                fontSize: 14.sp,
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
                  ),
                ),
                SizedBox(height: 16.h.clamp(12, 20).toDouble()),
                _buildTextField(
                  controller: _targetController,
                  label: 'Target Profit (%)',
                  hint: 'e.g., 2',
                ),
                SizedBox(height: 16.h.clamp(12, 20).toDouble()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _durationController,
                        label: 'Duration',
                        hint: 'e.g., 30',
                        isInteger: true,
                      ),
                    ),
                    SizedBox(width: 16.w.clamp(12, 20).toDouble()),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _durationType,
                        dropdownColor: AppColors.surface,
                        style: AppTypography.buttonText.copyWith(
                          fontSize: 14.sp.clamp(12, 16).toDouble(),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Type',
                          labelStyle: AppTypography.body.copyWith(
                            fontSize: 12.sp.clamp(10, 14).toDouble(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w.clamp(12, 20).toDouble(),
                            vertical: 16.h.clamp(12, 20).toDouble(),
                          ),
                        ),
                        items: ['Days', 'Weeks', 'Months']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _durationType = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48.h.clamp(32, 64).toDouble()),
                ElevatedButton(
                  onPressed: _calculateAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textMain,
                    minimumSize: Size(double.infinity, 54.h.clamp(46, 60).toDouble()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Create Plan',
                    style: AppTypography.buttonText,
                  ),
                ),
                SizedBox(height: 20.h.clamp(16, 24).toDouble()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isInteger = false,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTypography.buttonText.copyWith(
        fontSize: 14.sp.clamp(12, 16).toDouble(),
      ),
      keyboardType:
          TextInputType.numberWithOptions(decimal: !isInteger),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body.copyWith(
          fontSize: 12.sp.clamp(10, 14).toDouble(),
        ),
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(
          fontSize: 14.sp.clamp(12, 16).toDouble(),
          color: AppColors.textBody.withValues(alpha: 0.5),
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r.clamp(8, 16).toDouble()),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w.clamp(12, 20).toDouble(),
          vertical: 16.h.clamp(12, 20).toDouble(),
        ),
      ),
    );
  }
}
