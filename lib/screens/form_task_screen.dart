import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/constants.dart';
import '../widgets/task_form/task_due_date_field.dart';
import '../widgets/task_form/task_form_actions.dart';
import '../widgets/task_form/task_form_header.dart';
import '../widgets/task_form/task_options_row.dart';
import '../widgets/task_form/task_title_field.dart';

class FormTaskScreen extends StatefulWidget {
  /// Pass an existing task to edit it.
  /// Leave null to create a new task.
  final Task? task;

  const FormTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<FormTaskScreen> createState() => _FormTaskScreenState();
}

class _FormTaskScreenState extends State<FormTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  DateTime? _dueDateTime;
  late Priority _priority;
  late TaskTag _tag;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _titleController = TextEditingController(
      text: task?.title ?? '',
    );

    _dueDateTime = task?.dueDateTime;
    _priority = task?.priority ?? Priority.medium;
    _tag = task?.tag ?? TaskTag.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final initialDate = _dueDateTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _dueDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a due date and time.'),
        ),
      );

      return;
    }

    final result = Task(
      id: widget.task?.id ?? _generatePlaceholderId(),
      title: _titleController.text.trim(),
      dueDateTime: _dueDateTime!,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      priority: _priority,
      tag: _tag,
      isDone: widget.task?.isDone ?? false,
    );

    Navigator.of(context).pop(result);
  }

  String _generatePlaceholderId() {
    // Temporary ID for brand-new tasks until Firestore
    // wiring assigns a real document ID.
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  void _handlePriorityChanged(Priority? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _priority = value;
    });
  }

  void _handleTagChanged(TaskTag? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _tag = value;
    });
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildFormCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 440,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.subtext.withValues(alpha: 0.25),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TaskFormHeader(
              isEditing: _isEditing,
              onClose: _close,
            ),

            const SizedBox(height: 20),

            TaskTitleField(
              controller: _titleController,
            ),

            const SizedBox(height: 18),

            TaskDueDateField(
              dueDateTime: _dueDateTime,
              onTap: _pickDueDateTime,
            ),

            const SizedBox(height: 18),

            TaskOptionsRow(
              priority: _priority,
              tag: _tag,
              onPriorityChanged: _handlePriorityChanged,
              onTagChanged: _handleTagChanged,
            ),

            const SizedBox(height: 28),

            TaskFormActions(
              isEditing: _isEditing,
              onCancel: _close,
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}