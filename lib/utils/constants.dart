import 'package:flutter/material.dart';

enum Priority { low, medium, high }
enum TaskTag { school, personal, others }

extension PriorityX on Priority {
  String get label {
    switch (this) {
      case Priority.low: return 'Low';
      case Priority.medium: return 'Med';
      case Priority.high: return 'High';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low: return const Color(0xFF6FA671);    // green
      case Priority.medium: return const Color(0xFFE0A64B); // amber
      case Priority.high: return const Color(0xFFD9724F);   // orange-red
    }
  }
}

extension TaskTagX on TaskTag {
  String get label {
    switch (this) {
      case TaskTag.school: return 'School';
      case TaskTag.personal: return 'Personal';
      case TaskTag.others: return 'Others';
    }
  }
}

class AppColors {
  static const background = Color(0xFFF3EEE4); // warm cream
  static const cardBackground = Color(0xFFFFFFFF);
  static const heading = Color(0xFF3A2E26);     // dark brown
  static const subtext = Color(0xFF8C8478);
  static const tagBadgeBg = Color(0xFFF0E4D4);
  static const tagBadgeText = Color(0xFFB08A5A);
}