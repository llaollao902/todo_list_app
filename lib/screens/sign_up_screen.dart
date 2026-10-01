import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_translator.dart';
import '../utils/constants.dart';
import '../widgets/auth_form/auth_password_field.dart';
import '../widgets/auth_form/auth_submit_button.dart';
import '../widgets/auth_form/auth_text_field.dart';
import 'package:flutter/gestures.dart'; 


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Field-level validators ---
  // These run client-side, instantly, before any network request —
  // catching obvious mistakes (empty fields, bad email format, short
  // password) without waiting on Firebase.

  String? _validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name.';
    }
    return null; // null means "valid"
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    // Simple email format check — not exhaustive, but catches
    // obviously malformed input like "maya.lin" with no "@domain".
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  // --- Submit handler ---
  Future<void> _handleCreateAccount() async {
    // Trigger validation on all three fields at once. If any fail,
    // their error messages appear automatically under each field —
    // we don't need to display them ourselves.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );

      if (!mounted) return;

      // Account created and the user is now signed in (Firebase does
      // this automatically). Navigate into the app, replacing this
      // screen so the user can't go "back" into the sign-up form.
    } on FirebaseAuthException catch (e) {
      // This is where duplicate emails get caught: Firebase throws
      // 'email-already-in-use' here, which AuthErrorTranslator turns
      // into a readable message.
      if (!mounted) return;
      _showError(AuthErrorTranslator.translate(e));
    } catch (e) {
      // Catch-all for anything unexpected (e.g. no internet connection).
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Heading ---
                    const Text(
                      'Begin your quiet space.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        color: AppColors.heading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A calm place to organize your days and cultivate mindful focus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.subtext, height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // --- Display Name ---
                    AuthTextField(
                      label: 'Display Name',
                      hint: 'Maya Lin',
                      icon: Icons.badge_outlined,
                      controller: _displayNameController,
                      validator: _validateDisplayName,
                    ),
                    const SizedBox(height: 16),

                    // --- Email ---
                    AuthTextField(
                      label: 'Username or Email',
                      hint: 'maya.lin@domain.com',
                      icon: Icons.mail_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // --- Password ---
                    AuthPasswordField(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      controller: _passwordController,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 28),

                    // --- Submit ---
                    AuthSubmitButton(
                      label: 'Create account',
                      isLoading: _isLoading,
                      onPressed: _handleCreateAccount,
                    ),
                    const SizedBox(height: 20),

                    // --- Sign in link ---
                    RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(fontSize: 13, color: AppColors.subtext),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.heading,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Navigator.push to SignInScreen
                                // once that screen is built
                              },
                          ),
                        ],
                      ),
                    ),
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