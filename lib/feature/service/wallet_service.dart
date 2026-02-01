import 'package:get_storage/get_storage.dart';

class WalletService {
  static final _storage = GetStorage();
  static const _balanceKey = 'available_balance';

  static double get balance => _storage.read<double>(_balanceKey) ?? 0.0;

  static Future<void> deposit(double amount) async {
    final current = balance;
    await _storage.write(_balanceKey, current + amount);
  }

  static Future<void> withdraw(double amount) async {
    final current = balance;
    await _storage.write(_balanceKey, current - amount);
  }
}
