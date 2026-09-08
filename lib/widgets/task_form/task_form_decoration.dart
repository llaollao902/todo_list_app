import 'package:flutter/material.dart';

import '../../utils/constants.dart';

InputDecoration taskInputDecoration({
  String? hint,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: AppColors.subtext,
    ),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.subtext.withValues(alpha: 0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.subtext.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.heading,
        width: 1.5,
      ),
    ),
  );
}