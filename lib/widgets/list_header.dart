import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Header row above the task list: title + completed count on the left,
// Filter button on the right.
class ListHeader extends StatelessWidget {
  final String title;
  final int totalCount;
  final int completedCount;
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  const ListHeader({
    super.key,
    this.title = 'Your list',
    required this.totalCount,
    required this.completedCount,
    required this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeFilterCount > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title · $totalCount',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$completedCount completed',
                style: const TextStyle(fontSize: 12, color: AppColors.subtext),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: active ? AppColors.tagBadgeBg : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? AppColors.tagBadgeText
                    : AppColors.subtext.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune, size: 14, color: AppColors.heading),
                const SizedBox(width: 6),
                Text(
                  active ? 'Filter · $activeFilterCount' : 'Filter',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}