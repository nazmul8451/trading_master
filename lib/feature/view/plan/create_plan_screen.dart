import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        startCapital: double.parse(_capitalController.text),
        targetPercent: double.parse(_targetController.text),
        duration: int.parse(_durationController.text),
        durationType: _durationType,
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
      appBar: AppBar(
        title: const Text('Create Trading Plan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Plan Your Success',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                _buildTextField(
                  controller: _capitalController,
                  label: 'Starting Capital (\$)',
                  hint: 'e.g., 1000',
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                  controller: _targetController,
                  label: 'Target Profit (%)',
                  hint: 'e.g., 2',
                ),
                SizedBox(height: 16.h),
                Row(
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
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _durationType,
                        dropdownColor: const Color(0xFF1E222D),
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E222D),
                        ),
                        items: ['Days', 'Weeks', 'Months']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _durationType = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: _calculateAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2369FF),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Create Plan',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(decimal: !isInteger),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        filled: true,
        fillColor: const Color(0xFF1E222D),
      ),
    );
  }
}
