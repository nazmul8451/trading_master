import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PreferencesService {
  static final _storage = GetStorage();
  static const _notificationsKey = 'notifications_enabled';
  static const _biometricsKey = 'biometrics_enabled';

  static ValueNotifier<bool> notificationsNotifier = ValueNotifier(
    notificationsEnabled,
  );
  static ValueNotifier<bool> biometricsNotifier = ValueNotifier(
    biometricsEnabled,
  );

  static bool get notificationsEnabled =>
      _storage.read<bool>(_notificationsKey) ?? true;
  static bool get biometricsEnabled =>
      _storage.read<bool>(_biometricsKey) ?? false;

  static Future<void> setNotifications(bool enabled) async {
    await _storage.write(_notificationsKey, enabled);
    notificationsNotifier.value = enabled;
  }

  static const _themeModeKey = 'theme_mode';

  static ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(themeMode);

  static ThemeMode get themeMode {
    final mode = _storage.read<String>(_themeModeKey);
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _storage.write(_themeModeKey, modeStr);
    themeModeNotifier.value = mode;
  }

  static Future<void> setBiometrics(bool enabled) async {
    await _storage.write(_biometricsKey, enabled);
    biometricsNotifier.value = enabled;
  }
}
