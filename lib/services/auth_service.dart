import 'package:firebase_auth/firebase_auth.dart';

// Provides access to the app's Firebase Authentication state.
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Returns the signed-in user, or `null` when no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  // Emits the current user and later changes to the sign-in state.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}