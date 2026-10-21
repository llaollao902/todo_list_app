import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  // Keeps usernames/{username}.email in step with the email in Firebase Auth.
  // verifyBeforeUpdateEmail only changes the Auth email after the user clicks
  // the verification link, so we compare and fix it later, when the user is
  // back in the app

  Future<void> syncUsernameEmail() async {
    var user = currentUser;
    if (user == null) return;

    // pull the latest auth data so user.email reflects a verified change.
    await user.reload();
    user = currentUser;
    if (user == null || user.email == null) return;

    // refresh the id token so any rule that reads request.auth.token.email
    // sees the new address, not the old one
    await user.getIdToken(true);

    final snap = await _firestore
      .collection('usernames')
      .where('uid', isEqualTo: user.uid)
      .limit(1)
      .get();
    if (snap.docs.isEmpty) {
      debugPrint('syncUsernameEmail: no usernames doc for ${user.uid}');
      return;
    }

    final doc = snap.docs.first;
    debugPrint('syncUsernameEmail: auth=${user.email} '
        'firestore=${doc.data()['email']}');

    if (doc.data()['email'] != user.email) {
      await doc.reference.update({'email': user.email});
      debugPrint('syncUsernameEmail: updated');
    }
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

      // if the new username is already taken by another user, throw an error.
      if (newSnapshot.exists && newSnapshot.data()?['uid'] != user.uid) {
        throw FirebaseAuthException(code: 'username-already-in-use');
      }

      // if the old username is not owned by the current user, throw an error.
      if (oldRef != null && oldSnapshot?.data()?['uid'] == user.uid) {
        transaction.delete(oldRef);
      }

      // if the new username is available, create it.
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
    // If the identifier contains an '@', treat it as an email address.
    final email = await _resolveEmailForIdentifier(identifier);

    final credential =  await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // a failed sync must never block the user from signing in.
    try {
      await syncUsernameEmail();
    } catch (e) {
      debugPrint('syncUsernameEmail failed: $e');
    }

    return credential;
  }

  Future<void> sendPasswordResetEmailForIdentifier({
    required String identifier,
  }) async {
    final email = await _resolveEmailForIdentifier(identifier);
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> _resolveEmailForIdentifier(String identifier) async {
    final trimmedIdentifier = identifier.trim();
    if (trimmedIdentifier.contains('@')) return trimmedIdentifier;

    final username = _normalizeUsername(trimmedIdentifier);
    if (!_isValidUsername(username)) {
      throw FirebaseAuthException(code: 'invalid-username');
    }

    // Look up the username in Firestore to find the associated email.
    final usernameSnapshot = await _firestore
        .collection('usernames')
        .doc(username)
        .get();
    final accountEmail = usernameSnapshot.data()?['email'];

    // If the username doesn't exist or the email is not a string, throw an error.
    if (!usernameSnapshot.exists || accountEmail is! String) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    return accountEmail;
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

    // create the account with email and password
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

      // Use a transaction to ensure that the username is unique and not already taken.
      await _firestore.runTransaction((transaction) async {
        final existingUsername = await transaction.get(usernameRef);
        if (existingUsername.exists) {
          throw FirebaseAuthException(code: 'username-already-in-use');
        }
        
        // If the username is available, create it and associate it with the new user's UID and email.
        transaction.set(usernameRef, {'uid': user.uid, 'email': user.email});
      });
    } catch (_) {
      // if it fails, delete the newly created user to avoid leaving a partially created account.
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
      // must be 3-20 characters long, only lowercase letters, numbers, and underscores
      RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username);

  // Sign out
  Future<void> signOut() async {
    // Sign out from Firebase Authentication
    await _firebaseAuth.signOut();
  }
}
