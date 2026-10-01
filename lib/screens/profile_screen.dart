import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/auth_error_translator.dart';
import '../utils/constants.dart';
import '../widgets/auth_form/auth_password_field.dart';
import '../widgets/auth_form/auth_submit_button.dart';
import '../widgets/auth_form/auth_text_field.dart';
import '../widgets/profile/profile_avatar_header.dart';
import '../widgets/profile/section_header.dart';
import 'task_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onBackToTasks});

  final VoidCallback? onBackToTasks;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _isLoadingUsername = true;

  // Tracks whether the typed email differs from the signed-in user's
  // current email — the UI only needs to show "Available" once the
  // user has actually changed it, not for the unchanged original value.
  String _originalEmail = '';
  String _originalUsername = '';

  @override
  void initState() {
    super.initState();

    // Pre-fill from the currently signed-in Firebase user.
    final user = _authService.currentUser;
    _displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    _emailController = TextEditingController(text: user?.email ?? '');
    _usernameController = TextEditingController();
    _originalEmail = user?.email ?? '';
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    String? username;
    try {
      username = await _authService.getUsernameForCurrentUser();
    } catch (_) {
      // Keep the profile usable if the username mapping cannot be loaded.
    }

    if (!mounted) return;
    setState(() {
      _originalUsername = username ?? '';
      _usernameController.text = _originalUsername;
      _isLoadingUsername = false;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
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

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username can\'t be empty.';
    }
    if (!AuthService.isValidUsername(value)) {
      return 'Use 3-20 letters, numbers, or underscores.';
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

    if ((changingEmail || changingPassword) &&
        (value == null || value.isEmpty)) {
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
    final newUsername = AuthService.normalizeUsername(_usernameController.text);
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

      if (newUsername != _originalUsername) {
        await _authService.updateUsername(
          currentUsername: _originalUsername,
          newUsername: newUsername,
        );
      }

      await user.reload();

      if (!mounted) return;
      _showMessage('Profile updated successfully.', isError: false);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      setState(() {
        _originalUsername = newUsername;
        _usernameController.text = newUsername;
      });
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
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to log out. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final memberSince = user?.metadata.creationTime != null
        ? 'Member since ${_formatMonthYear(user!.metadata.creationTime!)}'
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.heading),
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              widget.onBackToTasks?.call();
            }
          },
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Avatar / name / handle ---
                Center(
                  child: ProfileAvatarHeader(
                    displayName: _displayNameController.text.isEmpty
                        ? 'Your name'
                        : _displayNameController.text,
                    username: _isLoadingUsername
                        ? 'Loading username'
                        : _usernameController.text.isEmpty
                        ? 'Username not set'
                        : '@${_usernameController.text}',
                    memberSince: memberSince,
                  ),
                ),
                const SizedBox(height: 28),

                // --- Profile Information section ---
                const SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Profile Information',
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    AuthTextField(
                      label: 'Username',
                      hint: 'Your username',
                      icon: Icons.alternate_email,
                      controller: _usernameController,
                      validator: _validateUsername,
                      suffixIcon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.subtext,
                      ),
                      helperText: _isLoadingUsername
                          ? 'Loading username...'
                          : 'Used to sign in to your account.',
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Display Name',
                      hint: 'Your name',
                      icon: Icons.badge_outlined,
                      controller: _displayNameController,
                      validator: _validateDisplayName,
                      suffixIcon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.subtext,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Email Address',
                      hint: 'you@domain.com',
                      icon: Icons.mail_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      suffixIcon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // --- Security & Password section ---
                const SectionHeader(
                  icon: Icons.lock_outline,
                  title: 'Security & Password',
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  children: [
                    AuthPasswordField(
                      label: 'Current Password',
                      hint: 'Required to change email or password',
                      controller: _currentPasswordController,
                      validator: _validateCurrentPassword,
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      label: 'New Password',
                      hint: 'Leave blank to keep your current password',
                      controller: _newPasswordController,
                      validator: _validateNewPassword,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // --- Save button ---
                AuthSubmitButton(
                  label: 'Save changes',
                  isLoading: _isSaving,
                  onPressed: _handleSaveChanges,
                ),
                const SizedBox(height: 16),

                // --- Log out ---
                Center(
                  child: TextButton.icon(
                    onPressed: _handleLogOut,
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Log out',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Groups a section's fields in the rounded card shown in the mockup.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtext.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
