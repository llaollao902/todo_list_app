import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class TaskFormHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onClose;

  const TaskFormHeader({
    super.key,
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditing ? 'EDIT TASK' : 'NEW TASK',
              style: TextStyle(
                letterSpacing: 1.2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.subtext,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.heading,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        Text(
          isEditing ? 'Update this task' : 'What needs doing?',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.heading,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }
}