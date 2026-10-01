import 'package:firebase_auth/firebase_auth.dart';

// Provides access to the app's Firebase Authentication state.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Returns the signed-in user, or `null` when no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  // Emits the current user and later changes to the sign-in state.
  // This is what lets the app automatically react to login/logout
  // anywhere, without manually checking "am I logged in?" everywhere.
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

  
  //   1. Create the account (email + password)
  //   2. Immediately update that new user's profile with the display name
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // updateDisplayName() modifies the profile of whichever user is
    // CURRENTLY signed in — and createUserWithEmailAndPassword
    // automatically signs the new user in immediately after creating
    // the account, so credential.user is that same new user.
    await credential.user?.updateDisplayName(displayName.trim());

    // reload() refreshes the local User object's cached data so that
    // .displayName reflects the update that just made. 
    await credential.user?.reload();

    return credential;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}