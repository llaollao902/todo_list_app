import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// Like AuthTextField, but adds a show/hide toggle (the eye icon in
// the mockup) since passwords need obscureText behavior that a plain
// text field doesn't have.
//
// This is a StatefulWidget (not Stateless like AuthTextField) because
// it needs to track whether the password is currently visible —
// that's local UI-only state, not something the parent form needs to
// know about.
class AuthPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true; // hidden by default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          style: const TextStyle(fontSize: 15, color: AppColors.heading),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.subtext),
            // Tapping the eye icon toggles _obscureText, revealing or
            // hiding the password text.
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.subtext,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            filled: true,
            fillColor: AppColors.tagBadgeBg.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}