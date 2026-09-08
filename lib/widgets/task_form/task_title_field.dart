import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'task_form_decoration.dart';

class TaskTitleField extends StatelessWidget {
  final TextEditingController controller;

  const TaskTitleField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TaskFieldLabel('Title'),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: taskInputDecoration(
            hint: 'e.g. Prepare presentation',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class TaskFieldLabel extends StatelessWidget {
  final String text;

  const TaskFieldLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.heading,
      ),
    );
  }
}