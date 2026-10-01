import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon; // NEW — lets callers show a pencil, check badge, etc.
  final String? helperText;  // NEW — small caption text under the field

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
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
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: AppColors.heading),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.subtext, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: AppColors.subtext),
            suffixIcon: suffixIcon, // NEW
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
        // Small caption under the field, e.g. "Appears across your tasks."
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.subtext),
            ),
          ),
        ],
      ],
    );
  }
}