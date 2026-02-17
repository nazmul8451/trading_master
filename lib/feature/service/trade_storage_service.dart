import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../model/trade_plan_model.dart';
import 'auth_service.dart';

class TradeStorageService {
  static const String _baseStorageKey = 'trade_sessions';
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  static String get storageKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseStorageKey}_$uid' : _baseStorageKey;
  }

  String get _storageKey => storageKey;

  // Collection reference for the current user
  CollectionReference<Map<String, dynamic>>? get _userPlansCollection {
    final uid = _auth.currentUid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('plans');
  }

  // Cache for deserialized data
  List<TradePlanModel>? _cachedSessions;
  String? _cachedDataHash;

  Future<void> saveTradeSession(TradePlanModel session) async {
    List<dynamic> sessions = _storage.read(_storageKey) ?? [];

    // Check if session already exists, if so update it, else add new
    int index = sessions.indexWhere((s) => s['id'] == session.id);
    if (index != -1) {
      sessions[index] = session.toJson();
    } else {
      sessions.add(session.toJson());
    }

    await _storage.write(_storageKey, sessions);
    _invalidateCache();

    // Background sync to Firestore
    _syncToFirestore(session);
  }

  Future<void> _syncToFirestore(TradePlanModel session) async {
    try {
      final collection = _userPlansCollection;
      if (collection != null) {
        await collection.doc(session.id).set(session.toJson());
      }
    } catch (e) {
      print("Error syncing to Firestore: $e");
    }
  }

  List<TradePlanModel> getAllTradeSessions() {
    List<dynamic> sessionsJson = _storage.read(_storageKey) ?? [];
    final currentHash = sessionsJson.length.toString();

    if (_cachedSessions != null && _cachedDataHash == currentHash) {
      return List.from(_cachedSessions!);
    }

    _cachedSessions = sessionsJson
        .map((json) => TradePlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _cachedDataHash = currentHash;

    return List.from(_cachedSessions!);
  }

  // Move data from global key to user-specific key
  Future<void> migrateLegacyData() async {
    final uid = _auth.currentUid;
    if (uid == null) return;

    final legacyData = _storage.read(_baseStorageKey);
    final currentData = _storage.read(_storageKey);

    print("Checking legacy trades for migration...");
    print("Legacy data found: ${legacyData != null}");
    print("Current user data found: ${currentData != null}");

    if (legacyData != null &&
        (currentData == null || (currentData is List && currentData.isEmpty))) {
      await _storage.write(_storageKey, legacyData);
      print("SUCCESS: Migrated legacy trades for user: $uid");
    }
  }

  // Fetch from Firestore and update local storage
  Future<void> syncFromFirestore() async {
    print("Syncing trades from Firestore...");
    try {
      await migrateLegacyData(); // Migrate before syncing

      final collection = _userPlansCollection;
      if (collection != null) {
        final snapshot = await collection.get();
        print("Firestore trades found: ${snapshot.docs.length}");

        if (snapshot.docs.isNotEmpty) {
          final sessions = snapshot.docs.map((doc) => doc.data()).toList();
          await _storage.write(_storageKey, sessions);
          print("Updated local storage with Firestore sessions.");
          _invalidateCache();
        } else {
          print("Firestore is empty, pushing local data to Firestore...");
          await pushToFirestore();
        }
      } else {
        print("Error: _userPlansCollection is null.");
      }
    } catch (e) {
      print("Error fetching from Firestore: $e");
    }
  }

  // Push all local data to Firestore
  Future<void> pushToFirestore() async {
    try {
      final collection = _userPlansCollection;
      if (collection == null) {
        print("Push aborted: Collection is null.");
        return;
      }

      List<TradePlanModel> sessions = getAllTradeSessions();
      print("Local sessions to push: ${sessions.length}");

      if (sessions.isEmpty) return;

      for (var session in sessions) {
        await collection.doc(session.id).set(session.toJson());
        print("Uploaded session: ${session.id}");
      }
      print("Successfully pushed ${sessions.length} sessions to Firestore.");
    } catch (e) {
      print("Error pushing to Firestore: $e");
    }
  }

  Future<void> deleteSession(String id) async {
    List<dynamic> sessions = _storage.read(_storageKey) ?? [];
    sessions.removeWhere((s) => s['id'] == id);
    await _storage.write(_storageKey, sessions);
    _invalidateCache();

    // Sync deletion to Firestore
    try {
      final collection = _userPlansCollection;
      if (collection != null) {
        await collection.doc(id).delete();
      }
    } catch (e) {
      print("Error deleting from Firestore: $e");
    }
  }

  Future<void> clearAllSessions() async {
    await _storage.remove(_storageKey);
    _invalidateCache();

    // Clear from Firestore
    try {
      final collection = _userPlansCollection;
      if (collection != null) {
        final snapshot = await collection.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error clearing Firestore: $e");
    }
  }

  void _invalidateCache() {
    _cachedSessions = null;
    _cachedDataHash = null;
  }
}
