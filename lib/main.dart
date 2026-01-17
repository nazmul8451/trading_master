import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routes/app_routes.dart';
import 'feature/view/dashboard/dashboard_screen.dart';
import 'feature/view/onboarding_screen/get_started.dart';
import 'feature/view/onboarding_screen/protocol_confirmation.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          title: 'Trade Manager',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2369FF),
              brightness: Brightness.dark,
            ),
          ),
          initialRoute: AppRoutes.getStarted,
          routes: {
            AppRoutes.getStarted: (context) => const GetStartedScreen(),
            AppRoutes.protocolConfirmation: (context) => const ProtocolConfirmationScreen(),
            AppRoutes.dashboard: (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}

