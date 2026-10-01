import 'package:firebase_auth/firebase_auth.dart';

// Converts Firebase's raw error codes into plain-English messages
class AuthErrorTranslator {
  static String translate(FirebaseAuthException e) {
    switch (e.code) {
      // Sign up specific
      case 'email-already-in-use':
        return 'An account already exists for that email address.';
      case 'weak-password':
        return 'That password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'That email address doesn\'t look valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are currently disabled.';

      // Sign-in specific
      case 'user-not-found':
        return 'No account found for that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';

      // --- Fallback for anything unexpected ---
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
