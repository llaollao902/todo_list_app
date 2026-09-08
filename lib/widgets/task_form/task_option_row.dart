import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../utils/constants.dart';
import 'task_form_decoration.dart';
import 'task_title_field.dart';

class TaskOptionsRow extends StatelessWidget {
  final Priority priority;
  final TaskTag tag;
  final ValueChanged<Priority?> onPriorityChanged;
  final ValueChanged<TaskTag?> onTagChanged;

  const TaskOptionsRow({
    super.key,
    required this.priority,
    required this.tag,
    required this.onPriorityChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PriorityField(
            value: priority,
            onChanged: onPriorityChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TagField(
            value: tag,
            onChanged: onTagChanged,
          ),
        ),
      ],
    );
  }
}

class _PriorityField extends StatelessWidget {
  final Priority value;
  final ValueChanged<Priority?> onChanged;

  const _PriorityField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TaskFieldLabel('Priority'),
        const SizedBox(height: 6),
        DropdownButtonFormField<Priority>(
          initialValue: value,
          decoration: taskInputDecoration(),
          items: Priority.values.map((priority) {
            return DropdownMenuItem<Priority>(
              value: priority,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: priority.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(priority.label),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _TagField extends StatelessWidget {
  final TaskTag value;
  final ValueChanged<TaskTag?> onChanged;

  const _TagField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TaskFieldLabel('Tag / category'),
        const SizedBox(height: 6),
        DropdownButtonFormField<TaskTag>(
          initialValue: value,
          decoration: taskInputDecoration(),
          items: TaskTag.values.map((tag) {
            return DropdownMenuItem<TaskTag>(
              value: tag,
              child: Text(tag.label),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}