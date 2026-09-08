import 'package:flutter/material.dart';
import '../utils/constants.dart';

// reusable dropdown widget.
class PillDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const PillDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true, 
          isDense: true,     
          hint: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.subtext),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.subtext),
          style: const TextStyle(fontSize: 12, color: AppColors.heading),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}