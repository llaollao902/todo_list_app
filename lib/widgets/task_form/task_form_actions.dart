import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class TaskFormActions extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const TaskFormActions({
    super.key,
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.subtext,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.heading,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            isEditing ? 'Save changes' : 'Add task',
          ),
        ),
      ],
    );
  }
}