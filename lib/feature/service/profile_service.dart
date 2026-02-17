import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ProfileService {
  static final _storage = GetStorage();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _baseNameKey = 'user_name';
  static const _baseTitleKey = 'user_title';

  static String get nameKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseNameKey}_$uid' : _baseNameKey;
  }

  static String get titleKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseTitleKey}_$uid' : _baseTitleKey;
  }

  static DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = AuthService().currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  static ValueNotifier<String> nameNotifier = ValueNotifier(name);
  static ValueNotifier<String> titleNotifier = ValueNotifier(title);

  static String get name {
    String? savedName = _storage.read<String>(nameKey);
    if (savedName != null && savedName.isNotEmpty) return savedName;

    String? firebaseName = AuthService().currentUser?.displayName;
    if (firebaseName != null && firebaseName.isNotEmpty) return firebaseName;

    return "Trader";
  }

  static String get title => _storage.read<String>(titleKey) ?? "Pro Trader";
  static String get email => AuthService().currentEmail ?? "Not available";

  static Future<void> updateProfile({String? name, String? title}) async {
    final uid = AuthService().currentUid;
    if (uid == null) return;

    Map<String, dynamic> updateData = {};

    if (name != null) {
      await _storage.write(nameKey, name);
      nameNotifier.value = name;
      updateData['name'] = name;
    }
    if (title != null) {
      await _storage.write(titleKey, title);
      titleNotifier.value = title;
      updateData['title'] = title;
    }

    // Sync to Firestore
    try {
      final doc = _userDoc;
      if (doc != null && updateData.isNotEmpty) {
        await doc.set(updateData, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error syncing profile: $e");
    }
  }

  static Future<void> migrateLegacyData() async {
    final uid = AuthService().currentUid;
    if (uid == null) return;

    // Migrate Name
    if (!_storage.hasData(nameKey) && _storage.hasData(_baseNameKey)) {
      final legacyName = _storage.read(_baseNameKey);
      if (legacyName != null) {
        await _storage.write(nameKey, legacyName);
        nameNotifier.value = legacyName;
        print("Migrated legacy name for user: $uid");
      }
    }

    // Migrate Title
    if (!_storage.hasData(titleKey) && _storage.hasData(_baseTitleKey)) {
      final legacyTitle = _storage.read(_baseTitleKey);
      if (legacyTitle != null) {
        await _storage.write(titleKey, legacyTitle);
        titleNotifier.value = legacyTitle;
        print("Migrated legacy title for user: $uid");
      }
    }
  }

  static Future<void> syncFromFirestore() async {
    try {
      await migrateLegacyData(); // Migrate before syncing

      final doc = _userDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            if (data['name'] != null) {
              await _storage.write(nameKey, data['name']);
              nameNotifier.value = data['name'];
            }
            if (data['title'] != null) {
              await _storage.write(titleKey, data['title']);
              titleNotifier.value = data['title'];
            }
          }
        } else {
          // Push local to firestore (including migrated) if cloud is empty
          await pushToFirestore();
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  static Future<void> pushToFirestore() async {
    try {
      final doc = _userDoc;
      if (doc != null) {
        await doc.set({'name': name, 'title': title}, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error pushing profile: $e");
    }
  }
}
