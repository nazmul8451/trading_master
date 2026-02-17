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
import '../../../core/utils/snackbar_helper.dart';

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
              SizedBox(height: 32.h),

              _buildSectionHeader("Account"),
              _buildSettingItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                title: "Wallet Management",
                subtitle: "Update balance & currency",
                onTap: () => _showWalletManager(context),
              ),
              _buildSettingItem(
                icon: Icons.person_outline,
                iconColor: const Color(0xFF8B5CF6),
                title: "Personal Details",
                subtitle: "Update name & profile",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                ),
              ),

              SizedBox(height: 16.h),
              _buildSectionHeader("Preferences"),
              ValueListenableBuilder<bool>(
                valueListenable: PreferencesService.notificationsNotifier,
                builder: (context, enabled, _) {
                  return _buildSettingItem(
                    icon: Icons.notifications_none_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: "Notifications",
                    subtitle: "Trade alerts & reminders",
                    trailing: Switch(
                      value: enabled,
                      onChanged: (val) =>
                          PreferencesService.setNotifications(val),
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: PreferencesService.themeModeNotifier,
                builder: (context, mode, _) {
                  String modeText = "System Default";
                  IconData modeIcon = Icons.brightness_auto_rounded;
                  if (mode == ThemeMode.light) {
                    modeText = "Light Mode";
                    modeIcon = Icons.light_mode_rounded;
                  } else if (mode == ThemeMode.dark) {
                    modeText = "Dark Mode";
                    modeIcon = Icons.dark_mode_rounded;
                  }

                  return _buildSettingItem(
                    icon: modeIcon,
                    iconColor: AppColors.primary,
                    title: "Theme Mode",
                    subtitle: modeText,
                    onTap: () => _showThemeSelector(context),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: PreferencesService.biometricsNotifier,
                builder: (context, enabled, _) {
                  return _buildSettingItem(
                    icon: Icons.fingerprint,
                    iconColor: const Color(0xFF10B981),
                    title: "Biometric Login",
                    subtitle: "Secure app with biometric",
                    trailing: Switch(
                      value: enabled,
                      onChanged: (val) => PreferencesService.setBiometrics(val),
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                    ),
                  );
                },
              ),

              SizedBox(height: 16.h),
              _buildSectionHeader("System"),
              _buildSettingItem(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF6366F1),
                title: "Export Data",
                subtitle: "Download journal as CSV",
                onTap: () => _handleExport(),
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                iconColor: AppColors.error,
                title: "Reset Data",
                subtitle: "Clear all trades & plans",
                isDestructive: true,
                onTap: () => _confirmReset(),
              ),

              SizedBox(height: 16.h),
              _buildSectionHeader("Info"),
              _buildSettingItem(
                icon: Icons.info_outline,
                iconColor: Colors.white60,
                title: "About App",
                subtitle: "Version & Developer info",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              _buildSettingItem(
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
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
        padding: EdgeInsets.all(24.r),
        borderRadius: 24.r,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        color: Colors.white.withOpacity(0.03),
        child: Row(
          children: [
            Container(
              width: 64.sp,
              height: 64.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, const Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ValueListenableBuilder<String>(
                  valueListenable: ProfileService.nameNotifier,
                  builder: (context, name, _) {
                    return Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: ProfileService.nameNotifier,
                    builder: (context, name, _) {
                      return Text(
                        name,
                        style: AppTypography.heading.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  ValueListenableBuilder<String>(
                    valueListenable: ProfileService.titleNotifier,
                    builder: (context, title, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: AppTypography.label.copyWith(
                              color: AppColors.getTextBody(
                                context,
                              ).withOpacity(0.5),
                              fontSize: 11.sp,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            ProfileService.email,
                            style: AppTypography.body.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.primary.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 8.w, top: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: AppTypography.label.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: AppColors.textBody.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        child: GlassContainer(
          borderRadius: 20.r,
          padding: EdgeInsets.zero,
          color: Colors.white.withOpacity(0.02),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: iconColor.withOpacity(0.1)),
                      ),
                      child: Icon(icon, size: 22.sp, color: iconColor),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.heading.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: isDestructive
                                  ? AppColors.error
                                  : Theme.of(context).brightness ==
                                        Brightness.dark
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: AppTypography.body.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.getTextBody(
                                context,
                              ).withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22.sp,
                        color: AppColors.textBody.withOpacity(0.3),
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
        SnackbarHelper.showSuccess(context, "Data exported successfully!");
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, "Export failed: $e");
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
                SnackbarHelper.showSuccess(context, "All data reset.");
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

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Theme",
              style: AppTypography.heading.copyWith(fontSize: 20.sp),
            ),
            SizedBox(height: 20.h),
            _buildThemeOption(
              context,
              ThemeMode.light,
              "Light Mode",
              Icons.light_mode_rounded,
            ),
            _buildThemeOption(
              context,
              ThemeMode.dark,
              "Dark Mode",
              Icons.dark_mode_rounded,
            ),
            _buildThemeOption(
              context,
              ThemeMode.system,
              "System Default",
              Icons.brightness_auto_rounded,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    String title,
    IconData icon,
  ) {
    final currentMode = PreferencesService.themeMode;
    final isSelected = currentMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textBody,
      ),
      title: Text(
        title,
        style: AppTypography.buttonText.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textMain,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        PreferencesService.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
