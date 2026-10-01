import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// A small section title with a leading icon, used to separate
// "Profile Information" from "Security & Password".
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.subtext),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
          ),
        ),
      ],
    );
  }
}