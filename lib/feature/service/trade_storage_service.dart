import 'package:get_storage/get_storage.dart';
import '../model/trade_plan_model.dart';

class TradeStorageService {
  static const String storageKey = 'trade_sessions';
  final GetStorage _storage = GetStorage();

  // Cache for deserialized data
  List<TradePlanModel>? _cachedSessions;
  String? _cachedDataHash;

  Future<void> saveTradeSession(TradePlanModel session) async {
    List<dynamic> sessions = _storage.read(storageKey) ?? [];

    // Check if session already exists, if so update it, else add new
    int index = sessions.indexWhere((s) => s['id'] == session.id);
    if (index != -1) {
      sessions[index] = session.toJson();
    } else {
      sessions.add(session.toJson());
    }

    await _storage.write(storageKey, sessions);
    _invalidateCache(); // Invalidate cache when data changes
  }

  List<TradePlanModel> getAllTradeSessions() {
    List<dynamic> sessionsJson = _storage.read(storageKey) ?? [];
    final currentHash = sessionsJson.length
        .toString(); // Simple hash based on length

    // Return cached data if available and valid
    if (_cachedSessions != null && _cachedDataHash == currentHash) {
      return List.from(
        _cachedSessions!,
      ); // Return a copy to prevent external modifications
    }

    // Deserialize and cache
    _cachedSessions = sessionsJson
        .map((json) => TradePlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _cachedDataHash = currentHash;

    return List.from(_cachedSessions!);
  }

  Future<void> deleteSession(String id) async {
    List<dynamic> sessions = _storage.read(storageKey) ?? [];
    sessions.removeWhere((s) => s['id'] == id);
    await _storage.write(storageKey, sessions);
    _invalidateCache(); // Invalidate cache when data changes
  }

  Future<void> clearAllSessions() async {
    await _storage.remove(storageKey);
    _invalidateCache(); // Invalidate cache when data changes
  }

  void _invalidateCache() {
    _cachedSessions = null;
    _cachedDataHash = null;
  }
}
