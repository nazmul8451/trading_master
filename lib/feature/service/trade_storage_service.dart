import 'package:get_storage/get_storage.dart';
import '../model/trade_plan_model.dart';

class TradeStorageService {
  static const String STORAGE_KEY = 'trade_sessions';
  final GetStorage _storage = GetStorage();

  Future<void> saveTradeSession(TradePlanModel session) async {
    List<dynamic> sessions = _storage.read(STORAGE_KEY) ?? [];

    // Check if session already exists, if so update it, else add new
    int index = sessions.indexWhere((s) => s['id'] == session.id);
    if (index != -1) {
      sessions[index] = session.toJson();
    } else {
      sessions.add(session.toJson());
    }

    await _storage.write(STORAGE_KEY, sessions);
  }

  List<TradePlanModel> getAllTradeSessions() {
    List<dynamic> sessionsJson = _storage.read(STORAGE_KEY) ?? [];
    return sessionsJson
        .map((json) => TradePlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSession(String id) async {
    List<dynamic> sessions = _storage.read(STORAGE_KEY) ?? [];
    sessions.removeWhere((s) => s['id'] == id);
    await _storage.write(STORAGE_KEY, sessions);
  }

  Future<void> clearAllSessions() async {
    await _storage.remove(STORAGE_KEY);
  }
}
