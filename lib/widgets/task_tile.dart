import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import 'badges.dart';

// Represents ONE task row/card in the list.
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format the due date/time like "Thu, Sep 10 · 6:30 PM"
    final formattedDueDate = DateFormat('EEE, MMM d · h:mm a').format(task.dueDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Checkbox (custom circle, tappable) ---
          GestureDetector(
            onTap: onToggleDone,
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.heading : Colors.transparent,
                border: Border.all(
                  color: task.isDone ? AppColors.heading : AppColors.subtext,
                  width: 1.5,
                ),
              ),
              // Show a small checkmark icon only when done
              child: task.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // --- Main content (title, date, badges) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Title takes remaining space so edit/delete icons
                    // stay pinned to the right even with long titles.
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: task.isDone ? AppColors.subtext : AppColors.heading,
                          // Strikethrough for completed tasks (visual distinction)
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    // --- Edit icon ---
                    GestureDetector(
                      onTap: onEdit,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.edit_outlined, size: 18, color: AppColors.subtext),
                      ),
                    ),
                    // --- Delete icon ---
                    GestureDetector(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.delete_outline, size: 18, color: AppColors.subtext),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // --- Due date row ---
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.subtext),
                    const SizedBox(width: 6),
                    Text(
                      formattedDueDate,
                      style: const TextStyle(fontSize: 12, color: AppColors.subtext),
                    ),
                    const Spacer(),
                    // Priority badge pinned to the right of the date row
                    PriorityBadge(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 8),

                // --- Tag badge ---
                TagBadge(tag: task.tag),
              ],
            ),
          ),
        ],
      ),
    );
  }
}