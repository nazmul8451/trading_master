import '../../feature/model/trade_plan_model.dart';
import '../../feature/model/transaction_model.dart';
import '../../feature/service/wallet_service.dart';
import '../../feature/service/trade_storage_service.dart';

class CompoundingPoint {
  final DateTime date;
  final double balance;

  CompoundingPoint(this.date, this.balance);
}

class _BalanceEvent {
  final DateTime date;
  final double change;
  _BalanceEvent(this.date, this.change);
}

class CompoundingCalculator {
  static List<CompoundingPoint> getHistoricalPoints() {
    final List<TradePlanModel> sessions = TradeStorageService()
        .getAllTradeSessions();
    final List<TransactionModel> transactions = WalletService.history;

    final List<_BalanceEvent> events = [];

    for (var tx in transactions) {
      events.add(
        _BalanceEvent(
          tx.timestamp,
          tx.type == TransactionType.deposit ? tx.amount : -tx.amount,
        ),
      );
    }

    for (var session in sessions) {
      double sessionNet = 0;
      for (var entry in session.entries) {
        if (entry.status == 'win') sessionNet += entry.potentialProfit;
        if (entry.status == 'loss') sessionNet -= entry.investAmount;
      }
      events.add(_BalanceEvent(session.date, sessionNet));
    }

    events.sort((a, b) => a.date.compareTo(b.date));

    List<CompoundingPoint> points = [];
    double currentBalance = 0;

    for (var event in events) {
      currentBalance += event.change;
      points.add(CompoundingPoint(event.date, currentBalance));
    }

    if (points.isEmpty) {
      points.add(CompoundingPoint(DateTime.now(), WalletService.balance));
    }

    return points;
  }

  static List<CompoundingPoint> getProjectedPoints(
    double targetPercent,
    int days,
  ) {
    final List<CompoundingPoint> history = getHistoricalPoints();
    double lastBalance = history.isNotEmpty
        ? history.last.balance
        : WalletService.balance;
    DateTime lastDate = history.isNotEmpty ? history.last.date : DateTime.now();

    List<CompoundingPoint> projected = [];
    // Start with the last known point
    projected.add(CompoundingPoint(lastDate, lastBalance));

    for (int i = 1; i <= days; i++) {
      lastBalance += lastBalance * (targetPercent / 100);
      lastDate = lastDate.add(const Duration(days: 1));
      projected.add(CompoundingPoint(lastDate, lastBalance));
    }

    return projected;
  }
}
