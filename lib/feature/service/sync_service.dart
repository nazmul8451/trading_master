import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'trade_storage_service.dart';
import 'journal_storage_service.dart';
import 'wallet_service.dart';
import 'profile_service.dart';

class SyncService {
  static final AuthService _auth = AuthService();

  static Future<void> syncAllData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("Sync aborted: No Firebase user logged in.");
      return;
    }

    print("--- Starting Full Data Sync ---");
    print("User ID: ${user.uid}");
    print("User Email: ${user.email}");
    print(
      "Firebase Project ID: ${FirebaseFirestore.instance.app.options.projectId}",
    );
    print("Firebase App ID: ${FirebaseFirestore.instance.app.options.appId}");

    try {
      await _performSyncWithTimeout(user);
      print("--- Data Sync Process Finished ---");
    } catch (e, stack) {
      print("!!! Data Sync Error: $e");
      print(stack);
    }
  }

  static Future<void> _performSyncWithTimeout(User user) async {
    try {
      print("Step 1: Testing Connection...");
      await FirebaseFirestore.instance
          .collection('test_connection')
          .doc('test')
          .set({
            'status': 'online',
            'last_tested': FieldValue.serverTimestamp(),
            'uid': user.uid,
          })
          .timeout(const Duration(seconds: 5));
      print("SUCCESS: Connection test passed!");

      print("Step 2: Syncing Services...");
      await Future.wait([
        _syncWithTimeout("Trades", TradeStorageService().syncFromFirestore()),
        _syncWithTimeout(
          "Journals",
          JournalStorageService().syncFromFirestore(),
        ),
        _syncWithTimeout("Wallet", WalletService.syncFromFirestore()),
        _syncWithTimeout("Profile", ProfileService.syncFromFirestore()),
      ]);
      print("SUCCESS: All services sync attempted.");
    } catch (e) {
      if (e is TimeoutException) {
        print("ALERT: Sync timed out at Step 1 or 2. Check network/Rules.");
      } else {
        print("ALERT: Sync failed: $e");
      }
      rethrow;
    }
  }

  static Future<void> _syncWithTimeout(
    String name,
    Future<void> syncFuture,
  ) async {
    try {
      print("Syncing $name...");
      await syncFuture.timeout(const Duration(seconds: 10));
      print("Done: $name synced.");
    } catch (e) {
      print("Failed: $name sync error ($e)");
    }
  }
}
