import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Shown when the task list is empty 
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    this.title = 'Nothing brewing yet',
    this.subtitle =
        'Take a sip, then tap + when you\'re ready to brew your next task.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Circle icon  ---
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tagBadgeBg,
              border: Border.all(
                color: AppColors.tagBadgeText.withValues(alpha: 0.4), 
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.coffee_outlined,
              size: 26,
              color: AppColors.tagBadgeText,
            ),
          ),
          const SizedBox(height: 18),

          // --- Title ---
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),

          // --- Subtitle ---
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subtext,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}