class PlanModel {
  final double startCapital;
  final double targetPercent;
  final int duration;
  final String durationType; // 'Days', 'Weeks', 'Months'
  final DateTime startDate;

  PlanModel({
    required this.startCapital,
    required this.targetPercent,
    required this.duration,
    required this.durationType,
    required this.startDate,
  });
}

class PlanEntry {
  final int day;
  final DateTime date;
  final double startBalance;
  final double targetProfit;
  final double endBalance;

  PlanEntry({
    required this.day,
    required this.date,
    required this.startBalance,
    required this.targetProfit,
    required this.endBalance,
  });
}
