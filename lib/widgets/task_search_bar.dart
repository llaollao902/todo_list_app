import 'package:flutter/material.dart';
import '../utils/constants.dart';

// A reusable search bar widget.
class TaskSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

// Creates a [TaskSearchBar] widget.
  const TaskSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

// Builds the widget tree for the [TaskSearchBar].
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: AppColors.subtext, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.subtext, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}