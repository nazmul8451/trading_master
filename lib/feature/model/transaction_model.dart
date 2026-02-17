enum TransactionType { deposit, withdraw }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String? note;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: TransactionType.values[json['type']],
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }
}
