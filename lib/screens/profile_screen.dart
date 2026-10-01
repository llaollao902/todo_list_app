import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_translator.dart';
import '../utils/constants.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isSaving = false;

  // Tracks whether the typed email differs from the signed-in user's
  // current email — the UI only needs to show "Available" once the
  // user has actually changed it, not for the unchanged original value.
  String _originalEmail = '';

  @override
  void initState() {
    super.initState();

    // Pre-fill from the currently signed-in Firebase user.
    final user = _authService.currentUser;
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _originalEmail = user?.email ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name can\'t be empty.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email can\'t be empty.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  // New password is OPTIONAL here — only validated if the user
  // actually typed something, since changing the password isn't
  // required every time they save profile changes.
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null; // leaving it blank is fine — means "don't change it"
    }
    if (value.length < 8) {
      return 'New password must be at least 8 characters.';
    }
    return null;
  }

  // Firebase requires re-authentication with the CURRENT password
  // before allowing a sensitive change (email or password update).
  // This is a security measure: it proves the person making the
  // change actually knows the existing credentials, in case the
  // session token was stolen/left logged in on a shared device.
  String? _validateCurrentPassword(String? value) {
    final changingEmail = _emailController.text.trim() != _originalEmail;
    final changingPassword = _newPasswordController.text.isNotEmpty;

    if ((changingEmail || changingPassword) && (value == null || value.isEmpty)) {
      return 'Enter your current password to confirm changes.';
    }
    return null;
  }

  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _authService.currentUser;
    if (user == null || user.email == null) return;

    final newEmail = _emailController.text.trim();
    final newDisplayName = _displayNameController.text.trim();
    final newPassword = _newPasswordController.text;
    final currentPassword = _currentPasswordController.text;

    final emailChanged = newEmail != _originalEmail;
    final passwordChanged = newPassword.isNotEmpty;

    setState(() => _isSaving = true);

    try {
      // Re-authenticate FIRST if either sensitive field is changing —
      // Firebase will reject updateEmail/updatePassword otherwise.
      if (emailChanged || passwordChanged) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Display name is always safe to update directly.
      if (newDisplayName != user.displayName) {
        await user.updateDisplayName(newDisplayName);
      }

      // Email update — Firebase itself rejects duplicates here,
      // same as during sign-up.
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      if (passwordChanged) {
        await user.updatePassword(newPassword);
      }

      await user.reload();

      if (!mounted) return;
      _showMessage('Profile updated successfully.', isError: false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      if (emailChanged) {
        _showMessage(
          'Check your new email inbox to confirm the change.',
          isError: false,
        );
      } else {
        setState(() => _originalEmail = newEmail);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(AuthErrorTranslator.translate(e), isError: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.heading,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogOut() async {
    await _authService.signOut();
    if (!mounted) return;
    // TODO: navigate back to the Sign In screen, clearing the stack:
    // Navigator.pushAndRemoveUntil(context,
    //   MaterialPageRoute(builder: (_) => const SignInScreen()),
    //   (route) => false);
  }

 