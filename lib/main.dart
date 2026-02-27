import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routes/app_routes.dart';
import 'feature/view/dashboard/dashboard_screen.dart';
import 'feature/view/auth/splash_screen.dart';
import 'feature/view/auth/onboarding_screen.dart';
import 'feature/view/auth/login_screen.dart';
import 'feature/view/auth/signup_screen.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();
  runApp(
    kDebugMode
        ? DevicePreview(enabled: false, builder: (context) => const MyApp())
        : const MyApp(),
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
          locale: kDebugMode ? DevicePreview.locale(context) : null,
          builder: kDebugMode ? DevicePreview.appBuilder : null,
          debugShowCheckedModeBanner: false,
          title: 'Trade Manager',
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2369FF),
              brightness: Brightness.dark,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0D1117),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 18.sp.clamp(16, 20).toDouble(),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 24.sp.clamp(20, 28).toDouble(),
              ),
            ),
          ),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.signup: (context) => const SignupScreen(),
            AppRoutes.dashboard: (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
