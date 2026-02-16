import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/premium_background.dart';
import '../../../../core/widgets/glass_container.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = "";
  String _buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About App",
          style: AppTypography.heading.copyWith(fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: PremiumBackground(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 100.h, 20.w, 20.h),
          child: Column(
            children: [
              GlassContainer(
                padding: EdgeInsets.all(32.r),
                borderRadius: 24.r,
                child: Column(
                  children: [
                    Container(
                      width: 80.sp,
                      height: 80.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "Trading Master",
                      style: AppTypography.heading.copyWith(fontSize: 24.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Version $_version ($_buildNumber)",
                      style: AppTypography.body.copyWith(
                        color: AppColors.textBody.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    SizedBox(height: 16.h),
                    _buildInfoRow("Developer", "Rimon Islam"),
                    SizedBox(height: 16.h),
                    _buildInfoRow("Contact", "support@tradingmaster.com"),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLinkButton(
                          "Privacy Policy",
                          "https://example.com/privacy",
                        ),
                        _buildLinkButton(
                          "Terms of Service",
                          "https://example.com/terms",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                "© ${DateTime.now().year} Trading Master. All rights reserved.",
                style: AppTypography.caption.copyWith(
                  color: AppColors.textBody.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(
            color: AppColors.textBody.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLinkButton(String label, String url) {
    return TextButton(
      onPressed: () => _launchUrl(url),
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, decoration: TextDecoration.underline),
      ),
    );
  }
}
