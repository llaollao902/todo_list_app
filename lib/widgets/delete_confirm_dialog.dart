import 'package:flutter/material.dart';
import '../utils/constants.dart';

// A reusable confirmation dialog shown before deleting a task.
class DeleteConfirmDialog extends StatelessWidget {
  final String taskTitle;

  const DeleteConfirmDialog({
    super.key,
    required this.taskTitle,
  });

  static Future<bool> show(BuildContext context, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmDialog(taskTitle: taskTitle),
    );
    // showDialog returns null if the user dismisses it by tapping
    // outside the dialog — treat that the same as "cancelled".
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Delete task?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.heading,
        ),
      ),
      content: Text(
        '"$taskTitle" will be removed from your list.',
        style: const TextStyle(color: AppColors.subtext),
      ),
      actions: [
        // Cancel — pops with `false`
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.subtext),
          ),
        ),
        // Delete — pops with `true`
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}