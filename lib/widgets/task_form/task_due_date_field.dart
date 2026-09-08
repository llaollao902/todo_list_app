import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'task_form_decoration.dart';
import 'task_title_field.dart';

class TaskDueDateField extends StatelessWidget {
  final DateTime? dueDateTime;
  final VoidCallback onTap;

  const TaskDueDateField({
    super.key,
    required this.dueDateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TaskFieldLabel('Due date and time'),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: taskInputDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dueDateTime != null
                      ? _formatDateTime(dueDateTime!)
                      : 'Select date and time',
                  style: TextStyle(
                    color: dueDateTime != null
                        ? AppColors.heading
                        : AppColors.subtext,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.subtext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final hour12 = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$date $hour12:$minute $period';
  }
}