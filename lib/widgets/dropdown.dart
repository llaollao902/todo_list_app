import 'package:flutter/material.dart';
import '../utils/constants.dart';

// A generic reusable "pill" styled dropdown.
class PillDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

// Creates a [PillDropdown] widget.
  const PillDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

// Builds the widget tree for the [PillDropdown].
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.subtext)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.subtext),
          style: const TextStyle(fontSize: 13, color: AppColors.heading),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}