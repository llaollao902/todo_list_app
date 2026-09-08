// lib/widgets/task_form/field_label.dart
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

// A simple widget to display a label for a form field.
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

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