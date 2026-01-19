class PlanModel {
  final String id;
  final double startCapital;
  final double targetPercent;
  final int duration;
  final String durationType; // 'Days', 'Weeks', 'Months'
  final DateTime startDate;
  final Map<int, String> dailyStatuses; // Day -> 'hit' | 'sl'

  PlanModel({
    required this.id,
    required this.startCapital,
    required this.targetPercent,
    required this.duration,
    required this.durationType,
    required this.startDate,
    this.dailyStatuses = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startCapital': startCapital,
      'targetPercent': targetPercent,
      'duration': duration,
      'durationType': durationType,
      'startDate': startDate.toIso8601String(),
      'dailyStatuses': dailyStatuses.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startCapital: (json['startCapital'] as num).toDouble(),
      targetPercent: (json['targetPercent'] as num).toDouble(),
      duration: json['duration'],
      durationType: json['durationType'],
      startDate: DateTime.parse(json['startDate']),
      dailyStatuses: Map<int, String>.from(
        (json['dailyStatuses'] ?? {}).map(
          (key, value) => MapEntry(int.parse(key.toString()), value.toString()),
        ),
      ),
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
