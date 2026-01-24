class TradeEntryModel {
  final int step;
  final double investAmount;
  final double potentialProfit;
  final String status; // 'pending', 'win', 'loss'
  final bool isRecovery;

  TradeEntryModel({
    required this.step,
    required this.investAmount,
    required this.potentialProfit,
    this.status = 'pending',
    this.isRecovery = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'investAmount': investAmount,
      'potentialProfit': potentialProfit,
      'status': status,
      'isRecovery': isRecovery,
    };
  }

  factory TradeEntryModel.fromJson(Map<String, dynamic> json) {
    return TradeEntryModel(
      step: json['step'],
      investAmount: (json['investAmount'] as num).toDouble(),
      potentialProfit: (json['potentialProfit'] as num).toDouble(),
      status: json['status'],
      isRecovery: json['isRecovery'] ?? false,
    );
  }

  TradeEntryModel copyWith({String? status, bool? isRecovery}) {
    return TradeEntryModel(
      step: step,
      investAmount: investAmount,
      potentialProfit: potentialProfit,
      status: status ?? this.status,
      isRecovery: isRecovery ?? this.isRecovery,
    );
  }
}

class TradePlanModel {
  final String id;
  final double balance;
  final double targetProfit;
  final double stopLossLimit;
  final double payoutPercentage;
  final String currency;
  final DateTime date;
  final List<TradeEntryModel> entries;

  TradePlanModel({
    required this.id,
    required this.balance,
    required this.targetProfit,
    required this.stopLossLimit,
    required this.payoutPercentage,
    required this.currency,
    required this.date,
    required this.entries,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'targetProfit': targetProfit,
      'stopLossLimit': stopLossLimit,
      'payoutPercentage': payoutPercentage,
      'currency': currency,
      'date': date.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  factory TradePlanModel.fromJson(Map<String, dynamic> json) {
    return TradePlanModel(
      id: json['id'],
      balance: (json['balance'] as num).toDouble(),
      targetProfit: (json['targetProfit'] as num).toDouble(),
      stopLossLimit: (json['stopLossLimit'] as num).toDouble(),
      payoutPercentage: (json['payoutPercentage'] as num?)?.toDouble() ?? 82.0,
      currency: json['currency'] ?? '\$',
      date: DateTime.parse(json['date']),
      entries: (json['entries'] as List)
          .map((e) => TradeEntryModel.fromJson(e))
          .toList(),
    );
  }
}
