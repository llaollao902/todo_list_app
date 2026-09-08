import 'package:flutter/material.dart';

// enums for task priority and tags
enum Priority { low, medium, high }
enum TaskTag { school, personal, others }

// extension methods to get label and color for Priority enum
extension PriorityX on Priority {
  String get label {
    switch (this) {
      case Priority.low: return 'Low';
      case Priority.medium: return 'Med';
      case Priority.high: return 'High';
    }
  }

// extension method to get color for Priority enum
  Color get color {
    switch (this) {
      case Priority.low: return const Color(0xFF6FA671);    
      case Priority.medium: return const Color(0xFFE0A64B); 
      case Priority.high: return const Color(0xFFD9724F);  
    }
  }
}

// extension method to get label for TaskTag enum
extension TaskTagX on TaskTag {
  String get label {
    switch (this) {
      case TaskTag.school: return 'School';
      case TaskTag.personal: return 'Personal';
      case TaskTag.others: return 'Others';
    }
  }
}

// color constants for the app
class AppColors {
  static const background = Color(0xFFF3EEE4); 
  static const cardBackground = Color(0xFFFFFFFF);
  static const heading = Color(0xFF3A2E26);    
  static const subtext = Color(0xFF8C8478);
  static const tagBadgeBg = Color(0xFFF0E4D4);
  static const tagBadgeText = Color(0xFFB08A5A);
}