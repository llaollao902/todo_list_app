import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Color comes from the Priority enum extension we defined earlier.
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: priority.color, // full-strength color for the text
        ),
      ),
    );
  }
}

// Small neutral pill showing the task's tag/category (School, Personal, Others).
class TagBadge extends StatelessWidget {
  final TaskTag tag;
  const TagBadge({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tagBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // shrink to fit content, not full width
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.tagBadgeText),
          const SizedBox(width: 6),
          Text(
            tag.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.tagBadgeText,
            ),
          ),
        ],
      ),
    );
  }
}