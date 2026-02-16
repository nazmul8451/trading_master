import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/premium_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_entrance.dart';
import '../../service/wallet_service.dart';
import '../../service/profile_service.dart';
import '../../service/preferences_service.dart';
import '../../service/data_service.dart';
import 'sub_screens/profile_edit_screen.dart';
import 'sub_screens/about_screen.dart';
import '../../service/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                ),
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("Preferences"),
              ValueListenableBuilder<bool>(
                valueListenable: PreferencesService.notificationsNotifier,
                builder: (context, enabled, _) {
                  return _buildSettingItem(
                    icon: Icons.notifications_none_rounded,
                    title: "Notifications",
                    subtitle: "Trade alerts & reminders",
                    trailing: Switch(
                      value: enabled,
                      onChanged: (val) =>
                          PreferencesService.setNotifications(val),
                      activeThumbColor: AppColors.primary,
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: PreferencesService.biometricsNotifier,
                builder: (context, enabled, _) {
                  return _buildSettingItem(
                    icon: Icons.fingerprint,
                    title: "Biometric Login",
                    subtitle: "Secure app with fingerprint",
                    trailing: Switch(
                      value: enabled,
                      onChanged: (val) => PreferencesService.setBiometrics(val),
                      activeThumbColor: AppColors.primary,
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("Data"),
              _buildSettingItem(
                icon: Icons.download_outlined,
                title: "Export Data",
                subtitle: "Download journal as CSV",
                onTap: () => _handleExport(),
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: "Reset Data",
                subtitle: "Clear all trades & plans",
                isDestructive: true,
                onTap: () => _confirmReset(),
              ),

              SizedBox(height: 24.h),
              _buildSectionHeader("About"),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: "About App",
                subtitle: "Version & Info",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              SizedBox(height: 24.h),
              _buildSettingItem(
                icon: Icons.logout_rounded,
                title: "Logout",
                subtitle: "Sign out of your account",
                isDestructive: true,
                onTap: () => _handleLogout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout() async {
    final authService = AuthService();
    await authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
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
                child: ValueListenableBuilder<String>(
                  valueListenable: ProfileService.nameNotifier,
                  builder: (context, name, _) {
                    return Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: ProfileService.nameNotifier,
                  builder: (context, name, _) {
                    return Text(
                      name,
                      style: AppTypography.subHeading.copyWith(fontSize: 18.sp),
                    );
                  },
                ),
                SizedBox(height: 4.h),
                ValueListenableBuilder<String>(
                  valueListenable: ProfileService.titleNotifier,
                  builder: (context, title, _) {
                    return Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textBody,
                        fontSize: 14.sp,
                      ),
                    );
                  },
                ),
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
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
                        Icons.chevron_right, // Fixed: removed .outlined
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
            // Use StatefulWidget to update balance inside dialog
            StatefulBuilder(
              builder: (context, setState) {
                return Text(
                  "Current Balance: \$${WalletService.balance.toStringAsFixed(2)}",
                  style: AppTypography.body,
                );
              },
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
                    onPressed: () async {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        await WalletService.deposit(amount);
                        if (context.mounted) Navigator.pop(context);
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
                    onPressed: () async {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount > 0) {
                        await WalletService.withdraw(amount);
                        if (context.mounted) Navigator.pop(context);
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

  void _handleExport() async {
    try {
      await DataService.exportData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Data exported successfully!",
              style: AppTypography.body,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export failed: $e", style: AppTypography.body),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Reset All Data", style: AppTypography.subHeading),
        content: Text(
          "Are you sure you want to delete all trades, plans, and settings? This action cannot be undone.",
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: AppColors.textBody)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DataService.resetAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("All data reset.", style: AppTypography.body),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Confirm Reset"),
          ),
        ],
      ),
    );
  }
}
