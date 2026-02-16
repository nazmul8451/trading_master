import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  static final _storage = GetStorage();
  static const _nameKey = 'user_name';
  static const _titleKey = 'user_title';

  static ValueNotifier<String> nameNotifier = ValueNotifier(name);
  static ValueNotifier<String> titleNotifier = ValueNotifier(title);

  static String get name => _storage.read<String>(_nameKey) ?? "Trader";
  static String get title => _storage.read<String>(_titleKey) ?? "Pro Trader";

  static Future<void> updateProfile({String? name, String? title}) async {
    if (name != null) {
      await _storage.write(_nameKey, name);
      nameNotifier.value = name;
    }
    if (title != null) {
      await _storage.write(_titleKey, title);
      titleNotifier.value = title;
    }
  }
}
