import 'package:firebase_auth/firebase_auth.dart';

/// Provides access to the app's Firebase Authentication state.
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Returns the signed-in user, or `null` when no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Emits the current user and later changes to the sign-in state.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

}