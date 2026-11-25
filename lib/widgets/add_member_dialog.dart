import 'package:flutter/material.dart';

import '../utils/constants.dart';

// asks for the username or email of the person to add to a collab list.
// returns the trimmed text, or null if the user cancels.
class AddMemberDialog extends StatefulWidget {
  final String listName;

  const AddMemberDialog({super.key, required this.listName});

  static Future<String?> show(BuildContext context, {required String listName}) {
    return showDialog<String>(
      context: context,
      builder: (_) => AddMemberDialog(listName: listName),
    );
  }

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add a member',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.heading),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'They will be able to see and edit the tasks in "${widget.listName}".',
            style: const TextStyle(fontSize: 13, color: AppColors.subtext),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'Username or email',
              hintStyle: TextStyle(color: AppColors.subtext),
              prefixIcon: Icon(Icons.person_add_alt_1_outlined, size: 20),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.subtext)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Add',
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