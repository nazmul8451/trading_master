import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Get current user
  User? get currentUser => _auth.currentUser;

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

      // Save user info locally
      await _storage.write('user_name', name);
      await _storage.write('user_email', email);
      await _storage.write('is_logged_in', true);

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
        await _storage.write('user_name', credential.user!.displayName);
      }

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
        return 'পাসওয়ার্ড খুব দুর্বল। কমপক্ষে ৬ অক্ষর ব্যবহার করুন।';
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে ইতিমধ্যে একাউন্ট আছে।';
      case 'user-not-found':
        return 'এই ইমেইল দিয়ে কোন একাউন্ট পাওয়া যায়নি।';
      case 'wrong-password':
        return 'ভুল পাসওয়ার্ড।';
      case 'invalid-email':
        return 'ইমেইল ঠিকানা সঠিক নয়।';
      case 'user-disabled':
        return 'এই একাউন্ট নিষ্ক্রিয় করা হয়েছে।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ নেই।';
      default:
        return 'একটি ত্রুটি ঘটেছে: ${e.message}';
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
