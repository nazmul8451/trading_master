import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';
import '../../service/wallet_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Settings",
          style: AppTypography.heading.copyWith(fontSize: 24.sp),
        ),
        centerTitle: true,
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 100.h, 20.w, 100.h),
          child: Column(
            children: [
              _buildProfileSection(),
              SizedBox(height: 24.h),
              _buildSectionHeader("Account"),
              _buildSettingItem(
                icon: Icons.account_balance_wallet_outlined,
                title: "Wallet Management",
                subtitle: "Update balance & currency",
                onTap: () => _showWalletManager(context),
              ),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: "Personal Details",
                subtitle: "Update name & profile",
                onTap: () {},
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("Preferences"),
              _buildSettingItem(
                icon: Icons.notifications_none_rounded,
                title: "Notifications",
                subtitle: "Trade alerts & reminders",
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                  activeColor: AppColors.primary,
                ),
              ),
              _buildSettingItem(
                icon: Icons.fingerprint,
                title: "Biometric Login",
                subtitle: "Secure app with fingerprint",
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                  activeColor: AppColors.primary,
                ),
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("Data"),
              _buildSettingItem(
                icon: Icons.download_outlined,
                title: "Export Data",
                subtitle: "Download journal as CSV",
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: "Reset Data",
                subtitle: "Clear all trades & plans",
                isDestructive: true,
                onTap: () {},
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("About"),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: "About App",
                subtitle: "Version 1.0.0",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return AnimatedEntrance(
      child: GlassContainer(
        padding: EdgeInsets.all(20.r),
        borderRadius: 20.r,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        child: Row(
          children: [
            Container(
              width: 60.sp,
              height: 60.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8B5CF6)],
                ),
              ),
              child: Center(
                child: Text(
                  "R",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rimon Islam",
                  style: AppTypography.subHeading.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Pro Trader",
                  style: AppTypography.body.copyWith(
                    color: AppColors.textBody,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTypography.subHeading.copyWith(
            fontSize: 14.sp,
            color: AppColors.textBody.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return AnimatedEntrance(
      delay: Duration(milliseconds: 100),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: GlassContainer(
          borderRadius: 16.r,
          padding: EdgeInsets.zero, // Handle padding in InkWell
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isDestructive
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        size: 20.sp,
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.buttonText.copyWith(
                              fontSize: 16.sp,
                              color: isDestructive
                                  ? AppColors.error
                                  : AppColors.textMain,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: AppTypography.body.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing
                    else
                      Icon(
                        Icons.chevron_right,
                        size: 20.sp,
                        color: AppColors.textBody.withOpacity(0.5),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWalletManager(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Manage Wallet", style: AppTypography.subHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Balance: \$${WalletService.balance.toStringAsFixed(2)}",
              style: AppTypography.body,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.body,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: AppTypography.body.copyWith(
                  color: AppColors.textBody,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        WalletService.deposit(amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text("Deposit"),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        WalletService.withdraw(amount);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text("Withdraw"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
