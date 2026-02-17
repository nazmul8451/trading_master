import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'profile_service.dart';
import 'sync_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Get current user UID
  String? get currentUid => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user email
  String? get currentEmail => _auth.currentUser?.email;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Save user info locally (User-specific)
      await _storage.write(ProfileService.nameKey, name);
      await _storage.write('user_email', email); // Global email is fine for now
      await _storage.write('is_logged_in', true);

      // Sync data after signup
      await SyncService.syncAllData();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login state
      await _storage.write('user_email', email);
      await _storage.write('is_logged_in', true);
      if (credential.user?.displayName != null) {
        await _storage.write(
          ProfileService.nameKey,
          credential.user!.displayName,
        );
      }

      // Sync data after signin
      await SyncService.syncAllData();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.write('is_logged_in', false);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    return _storage.read('onboarding_completed') ?? false;
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    await _storage.write('onboarding_completed', true);
  }
}
