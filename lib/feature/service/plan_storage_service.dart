import 'package:get_storage/get_storage.dart';
import '../model/plan_model.dart';

class PlanStorageService {
  static const String _storageKey = 'saved_plans';
  final GetStorage _storage = GetStorage();

  Future<void> savePlan(PlanModel plan) async {
    List<dynamic> plans = _storage.read(_storageKey) ?? [];
    plans.add(plan.toJson());
    await _storage.write(_storageKey, plans);
  }

  List<PlanModel> getAllPlans() {
    List<dynamic> plansJson = _storage.read(_storageKey) ?? [];
    return plansJson.map((json) => PlanModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  List<PlanModel> getPlansByType(String durationType) {
    return getAllPlans().where((plan) => plan.durationType == durationType).toList();
  }

  Future<void> deletePlan(int index) async {
    List<dynamic> plans = _storage.read(_storageKey) ?? [];
    if (index >= 0 && index < plans.length) {
      plans.removeAt(index);
      await _storage.write(_storageKey, plans);
    }
  }

  Future<void> clearAllPlans() async {
    await _storage.remove(_storageKey);
  }
}
