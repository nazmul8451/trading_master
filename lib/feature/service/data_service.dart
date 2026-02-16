import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'trade_storage_service.dart';
import 'profile_service.dart';

class DataService {
  static final TradeStorageService _tradeStorage = TradeStorageService();

  static Future<void> exportData() async {
    final sessions = _tradeStorage.getAllTradeSessions();

    // Create CSV Data
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "Plan ID",
      "Date",
      "Balance",
      "Target Profit",
      "Stop Loss Limit",
      "Payout %",
      "Currency",
      "Duration Type",
      "Total Entries",
    ]);

    // Rows
    for (var session in sessions) {
      rows.add([
        session.id,
        session.date.toIso8601String(),
        session.balance,
        session.targetProfit,
        session.stopLossLimit,
        session.payoutPercentage,
        session.currency,
        session.durationType,
        session.entries.length,
      ]);
    }

    String csvData = csv.encode(rows);

    // Save to device
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/trading_journal_export.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    // Share using share_plus 10.x API
    await Share.shareXFiles([XFile(path)], text: 'My Trading Journal Export');
  }

  static Future<void> resetAllData() async {
    // Clear Trades
    await _tradeStorage.clearAllSessions();

    // Clear all GetStorage data
    final storage = GetStorage();
    await storage.erase();

    // Reset Notifiers
    ProfileService.nameNotifier.value = "Trader";
    ProfileService.titleNotifier.value = "Pro Trader";
    // WalletService.balance is a getter from storage, so it will be 0.0
  }
}
