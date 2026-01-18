import '../model/plan_model.dart';

class PlanController {
  static List<PlanEntry> calculatePlan(PlanModel plan) {
    List<PlanEntry> entries = [];
    double currentBalance = plan.startCapital;

    for (int i = 1; i <= plan.duration; i++) {
      double profit = currentBalance * (plan.targetPercent / 100);
      double endBalance = currentBalance + profit;

      DateTime date;
      if (plan.durationType == 'Weeks') {
        date = plan.startDate.add(Duration(days: (i - 1) * 7));
      } else if (plan.durationType == 'Months') {
        date = plan.startDate.add(Duration(days: (i - 1) * 30));
      } else {
        date = plan.startDate.add(Duration(days: i - 1));
      }

      entries.add(PlanEntry(
        day: i,
        date: date,
        startBalance: currentBalance,
        targetProfit: profit,
        endBalance: endBalance,
      ));

      currentBalance = endBalance;
    }
    return entries;
  }
}
