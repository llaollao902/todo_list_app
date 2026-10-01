import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// A reusable labeled text field for auth forms (display name, email).
// Handles the "Label *" header + icon-prefixed rounded input styling
// shared across every field in the Sign Up / Sign In screens.
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Label row: "Display Name *" ---
        // RichText lets us color just the asterisk differently from
        // the rest of the label, matching the mockup.
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // --- Input field ---
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.heading),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: AppColors.subtext),
            filled: true,
            fillColor: AppColors.tagBadgeBg.withOpacity(0.5),
            // No border by default — rounded, borderless look like the mockup.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            // Red border only appears when validation fails.
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