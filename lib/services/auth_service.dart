import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provides access to the app's Firebase Authentication state.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Returns the signed-in user, or `null` when no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> getUsernameForCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final usernames = await _firestore
        .collection('usernames')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    return usernames.docs.isEmpty ? null : usernames.docs.first.id;
  }

  Future<void> updateUsername({
    required String currentUsername,
    required String newUsername,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final normalizedCurrent = _normalizeUsername(currentUsername);
    final normalizedNew = _normalizeUsername(newUsername);
    if (!_isValidUsername(normalizedNew)) {
      throw FirebaseAuthException(code: 'invalid-username');
    }
    if (normalizedCurrent == normalizedNew) return;

    final usernames = _firestore.collection('usernames');
    final oldRef = normalizedCurrent.isEmpty
        ? null
        : usernames.doc(normalizedCurrent);
    final newRef = usernames.doc(normalizedNew);

    await _firestore.runTransaction((transaction) async {
      final newSnapshot = await transaction.get(newRef);
      final oldSnapshot = oldRef == null ? null : await transaction.get(oldRef);

      if (newSnapshot.exists && newSnapshot.data()?['uid'] != user.uid) {
        throw FirebaseAuthException(code: 'username-already-in-use');
      }

      if (oldRef != null && oldSnapshot?.data()?['uid'] == user.uid) {
        transaction.delete(oldRef);
      }

      transaction.set(newRef, {'uid': user.uid, 'email': user.email});
    });
  }

  // Emits the current user and later changes to the sign-in state.
  // This is what lets the app automatically react to login/logout
  // anywhere, without manually checking "am I logged in?" everywhere.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with a username or email and password.
  Future<UserCredential> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
  }) async {
    final trimmedIdentifier = identifier.trim();
    var email = trimmedIdentifier;

    if (!trimmedIdentifier.contains('@')) {
      final username = _normalizeUsername(trimmedIdentifier);
      if (!_isValidUsername(username)) {
        throw FirebaseAuthException(code: 'invalid-username');
      }

      final usernameSnapshot = await _firestore
          .collection('usernames')
          .doc(username)
          .get();
      final accountEmail = usernameSnapshot.data()?['email'];
      if (!usernameSnapshot.exists || accountEmail is! String) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      email = accountEmail;
    }

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
    required String username,
  }) async {
    final normalizedUsername = _normalizeUsername(username);
    if (!_isValidUsername(normalizedUsername)) {
      throw FirebaseAuthException(code: 'invalid-username');
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return the newly created user.');
    }

    try {
      await user.updateDisplayName(displayName.trim());
      await user.reload();

      final usernameRef = _firestore
          .collection('usernames')
          .doc(normalizedUsername);

      await _firestore.runTransaction((transaction) async {
        final existingUsername = await transaction.get(usernameRef);
        if (existingUsername.exists) {
          throw FirebaseAuthException(code: 'username-already-in-use');
        }

        transaction.set(usernameRef, {'uid': user.uid, 'email': user.email});
      });
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        // Preserve the original registration error if cleanup fails.
      }
      rethrow;
    }

    return credential;
  }

  static String normalizeUsername(String username) =>
      _normalizeUsername(username);

  static bool isValidUsername(String username) =>
      _isValidUsername(_normalizeUsername(username));

  static String _normalizeUsername(String username) =>
      username.trim().toLowerCase();

  static bool _isValidUsername(String username) =>
      RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username);

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
