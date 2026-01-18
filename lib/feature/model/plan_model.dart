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

  Map<String, dynamic> toJson() {
    return {
      'startCapital': startCapital,
      'targetPercent': targetPercent,
      'duration': duration,
      'durationType': durationType,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      startCapital: json['startCapital'],
      targetPercent: json['targetPercent'],
      duration: json['duration'],
      durationType: json['durationType'],
      startDate: DateTime.parse(json['startDate']),
    );
  }
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
