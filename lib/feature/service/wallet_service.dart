import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../model/transaction_model.dart';
import 'auth_service.dart';

class WalletService {
  static final _storage = GetStorage();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const _baseBalanceKey = 'available_balance';
  static const _baseHistoryKey = 'transaction_history';

  static String get balanceKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseBalanceKey}_$uid' : _baseBalanceKey;
  }

  static String get historyKey {
    final uid = AuthService().currentUid;
    return uid != null ? '${_baseHistoryKey}_$uid' : _baseHistoryKey;
  }

  static DocumentReference<Map<String, dynamic>>? get _userWalletDoc {
    final uid = AuthService().currentUid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet')
        .doc('data');
  }

  static double get balance => _storage.read<double>(balanceKey) ?? 0.0;

  static List<TransactionModel> get history {
    final List<dynamic>? raw = _storage.read(historyKey);
    if (raw == null) return [];
    return raw.map((e) => TransactionModel.fromJson(e)).toList();
  }

  static Future<void> deposit(double amount, {String? note}) async {
    final current = balance;
    final newBalance = current + amount;
    await _storage.write(balanceKey, newBalance);
    await _addTransaction(TransactionType.deposit, amount, note);
    _syncToFirestore(newBalance);
  }

  static Future<void> withdraw(double amount, {String? note}) async {
    final current = balance;
    final newBalance = current - amount;
    await _storage.write(balanceKey, newBalance);
    await _addTransaction(TransactionType.withdraw, amount, note);
    _syncToFirestore(newBalance);
  }

  static Future<void> _addTransaction(
    TransactionType type,
    double amount,
    String? note,
  ) async {
    final List<dynamic> currentHistory = _storage.read(historyKey) ?? [];
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      timestamp: DateTime.now(),
      note: note,
    );
    currentHistory.add(tx.toJson());
    await _storage.write(historyKey, currentHistory);
  }

  static Future<void> _syncToFirestore(double newBalance) async {
    try {
      final doc = _userWalletDoc;
      if (doc != null) {
        await doc.set({
          'balance': newBalance,
          'lastUpdated': FieldValue.serverTimestamp(),
          'history': _storage.read(historyKey),
        });
      }
    } catch (e) {
      print("Error syncing wallet: $e");
    }
  }

  static Future<void> migrateLegacyData() async {
    final uid = AuthService().currentUid;
    if (uid == null) return;

    print("Checking legacy wallet for migration...");

    // Migrate Balance
    final legacyBalance = _storage.read(_baseBalanceKey);
    final currentBalance = _storage.read(balanceKey);
    if (legacyBalance != null && currentBalance == null) {
      await _storage.write(balanceKey, legacyBalance);
      print("SUCCESS: Migrated legacy balance for user: $uid");
    }

    // Migrate History
    final legacyHistory = _storage.read(_baseHistoryKey);
    final currentHistory = _storage.read(historyKey);
    if (legacyHistory != null &&
        (currentHistory == null ||
            (currentHistory is List && currentHistory.isEmpty))) {
      await _storage.write(historyKey, legacyHistory);
      print("SUCCESS: Migrated legacy history for user: $uid");
    }
  }

  static Future<void> syncFromFirestore() async {
    print("Syncing wallet from Firestore...");
    try {
      await migrateLegacyData(); // Migrate before syncing

      final doc = _userWalletDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        print("Firestore wallet exists: ${snapshot.exists}");
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            await _storage.write(
              balanceKey,
              (data['balance'] as num).toDouble(),
            );
            await _storage.write(historyKey, data['history'] ?? []);
            print("Updated local wallet from cloud.");
          }
        } else {
          print("Firestore wallet empty, pushing local...");
          await pushToFirestore();
        }
      } else {
        print("Error: _userWalletDoc is null.");
      }
    } catch (e) {
      print("Error fetching wallet: $e");
    }
  }

  static Future<void> pushToFirestore() async {
    try {
      final doc = _userWalletDoc;
      if (doc != null) {
        print("Pushing local wallet to cloud...");
        await doc.set({
          'balance': balance,
          'lastUpdated': FieldValue.serverTimestamp(),
          'history': _storage.read(historyKey) ?? [],
        });
        print("Successfully pushed wallet to Firestore.");
      } else {
        print("Push aborted: Wallet doc null.");
      }
    } catch (e) {
      print("Error pushing wallet: $e");
    }
  }
}
