import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

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

  static Future<void> setBiometrics(bool enabled) async {
    await _storage.write(_biometricsKey, enabled);
    biometricsNotifier.value = enabled;
  }
}
