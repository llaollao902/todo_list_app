import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/auth_error_translator.dart';
import '../utils/constants.dart';
import '../widgets/auth_form/auth_submit_button.dart';
import '../widgets/auth_form/auth_text_field.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key, this.initialIdentifier = ''});

  final String initialIdentifier;

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late final TextEditingController _identifierController;

  bool _isSending = false;
  bool _requestSent = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text: widget.initialIdentifier,
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    final identifier = value?.trim() ?? '';
    if (identifier.isEmpty) {
      return 'Enter your username or email address.';
    }

    if (identifier.contains('@')) {
      final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailPattern.hasMatch(identifier)) {
        return 'Please enter a valid email address.';
      }
    } else if (!AuthService.isValidUsername(identifier)) {
      return 'Use a username with 3-20 letters, numbers, or underscores.';
    }

    return null;
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      await _authService.sendPasswordResetEmailForIdentifier(
        identifier: _identifierController.text,
      );
      if (mounted) setState(() => _requestSent = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (error.code == 'user-not-found') {
        setState(() => _requestSent = true);
      } else if (error.code == 'invalid-email' ||
          error.code == 'invalid-username' ||
          error.code == 'too-many-requests' ||
          error.code == 'operation-not-allowed') {
        _showError(AuthErrorTranslator.translate(error));
      } else {
        _showError('Unable to send a reset link right now. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to send a reset link right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Password recovery',
          style: TextStyle(color: AppColors.heading),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset your password.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered username or email. We\'ll send a secure link to set a new password.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.subtext,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      label: 'Username or Email',
                      hint: 'juan_cruz or juan.cruz@domain.com',
                      icon: Icons.person_outline,
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateIdentifier,
                    ),
                    const SizedBox(height: 20),
                    AuthSubmitButton(
                      label: _requestSent
                          ? 'Resend reset link'
                          : 'Send reset link',
                      isLoading: _isSending,
                      onPressed: _sendResetEmail,
                    ),
                    if (_requestSent) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'If an account matches, a reset link has been sent. Open it to choose a new password, then return here to sign in.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subtext,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
