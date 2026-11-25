import 'package:flutter/material.dart';

import '../utils/constants.dart';

// asks for the name of a new collaborative list.
// returns the trimmed name, or null if the user cancels.
class NewListDialog extends StatefulWidget {
  const NewListDialog({super.key});

   // opens the dialog and returns the name, or null if canceled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const NewListDialog(),
    );
  }

  @override
  State<NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();

    // prevent creating a list with an empty or whitespace-only name
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'New collaborative list',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.heading,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'List name',
          labelStyle: TextStyle(color: AppColors.subtext),
          floatingLabelStyle: TextStyle(color: AppColors.heading),
          hintText: 'e.g. Group project',
          hintStyle: TextStyle(color: AppColors.subtext),
          helperStyle: TextStyle(color: AppColors.subtext),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.subtext),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Create',
            style: TextStyle(
              color: AppColors.heading,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}