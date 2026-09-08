import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Simple header row shown above the task list.
class ListHeader extends StatelessWidget {
  final int totalCount;
  final int completedCount;

  const ListHeader({
    super.key,
    required this.totalCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.sort, size: 16, color: AppColors.subtext),
        const SizedBox(width: 6),
        Text(
          'Your list · $totalCount',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
          ),
        ),
        const Spacer(),
        Text(
          '$completedCount completed',
          style: const TextStyle(fontSize: 12, color: AppColors.subtext),
        ),
      ],
    );
  }
}