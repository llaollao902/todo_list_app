import 'package:flutter/material.dart';

import '../../utils/constants.dart';

// The circular initials avatar + name + handle block at the top of
// the Profile screen.
class ProfileAvatarHeader extends StatelessWidget {
  final String displayName;
  final String username;
  final String memberSince;

  const ProfileAvatarHeader({
    super.key,
    required this.displayName,
    required this.username,
    required this.memberSince,
  });

  // Derives initials from the display name, e.g. "Juan Dela Cruz" -> "JD".
  // Falls back to "?" if the name is somehow empty.
  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts[0][0];
    final last = parts.length > 1 ? parts[1][0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFC9D6B8), // soft sage, matches mockup
          ),
          alignment: Alignment.center,
          child: Text(
            _initials,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            color: AppColors.heading,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$username · $memberSince',
          style: const TextStyle(fontSize: 12, color: AppColors.subtext),
        ),
      ],
    );
  }
}
