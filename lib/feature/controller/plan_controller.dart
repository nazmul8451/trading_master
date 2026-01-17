import '../model/plan_model.dart';

class PlanController {
  static List<PlanEntry> calculatePlan(PlanModel plan) {
    List<PlanEntry> entries = [];
    double currentBalance = plan.startCapital;

    for (int i = 1; i <= plan.duration; i++) {
      double profit = currentBalance * (plan.targetPercent / 100);
      double endBalance = currentBalance + profit;

      entries.add(PlanEntry(
        day: i,
        startBalance: currentBalance,
        targetProfit: profit,
        endBalance: endBalance,
      ));

      currentBalance = endBalance;
    }
    return entries;
  }
}
