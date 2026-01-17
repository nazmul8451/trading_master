class PlanModel {
  final double startCapital;
  final double targetPercent;
  final int duration;
  final String durationType; // 'Days', 'Weeks', 'Months'

  PlanModel({
    required this.startCapital,
    required this.targetPercent,
    required this.duration,
    required this.durationType,
  });
}

class PlanEntry {
  final int day;
  final double startBalance;
  final double targetProfit;
  final double endBalance;

  PlanEntry({
    required this.day,
    required this.startBalance,
    required this.targetProfit,
    required this.endBalance,
  });
}
