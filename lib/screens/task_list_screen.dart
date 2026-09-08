import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/filter_sort_bar.dart';
import '../widgets/list_header.dart';
import '../widgets/task_tile.dart';
import 'form_task_screen.dart';
import '../widgets/empty_state.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskTag? _selectedTagFilter;
  Priority? _selectedPriorityFilter;
  String _selectedSortOption = 'Date added';

  void _onTagChanged(TaskTag? tag) {
    setState(() => _selectedTagFilter = tag);
  }

  void _onPriorityChanged(Priority? priority) {
    setState(() => _selectedPriorityFilter = priority);
  }

  void _onSortChanged(String? sortOption) {
    setState(() => _selectedSortOption = sortOption ?? 'Date added');
  }

  // Toggles a task's isDone state and updates the UI.
  // Takes the task's id (not the whole object) so it's easy to call
  // this from anywhere just by knowing which task was tapped.
  void _toggleTaskDone(String taskId) {
    final provider = context.read<TaskProvider>();
    final task = provider.tasks.firstWhere((task) => task.id == taskId);
    provider.toggleTaskDone(task);
  }

  /// Navigates to [FormTaskScreen] to create a new task.
  Future<void> _addNewTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const FormTaskScreen()),
    );

    if (newTask != null && mounted) {
      await context.read<TaskProvider>().addTask(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;
    final completedCount = provider.completedCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Pinned sticky header section for better scrolling ergonomics
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 15),
                  FilterSortBar(
                    selectedTag: _selectedTagFilter,
                    selectedPriority: _selectedPriorityFilter,
                    selectedSort: _selectedSortOption,
                    onTagChanged: _onTagChanged,
                    onPriorityChanged: _onPriorityChanged,
                    onSortChanged: _onSortChanged,
                  ),
                  const SizedBox(height: 15),

                  // "Your list · N" / "N completed" — sits inside the
                  // pinned section, right above the scrollable list.
                  ListHeader(
                    totalCount: tasks.length,
                    completedCount: completedCount,
                  ),
                ],
              ),
            ),


            // Scrollable task area
            Expanded(
              child: tasks.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Align(
                        alignment: Alignment(0.0, -0.4),
                        child: EmptyState(),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: tasks.map(
                        (task) => TaskTile(
                          task: task,
                          onToggleDone: () => _toggleTaskDone(task.id),
                          onEdit: () {
                            // TODO: navigate to Add/Edit Task screen
                          },
                          onDelete: () {
                            // TODO: confirmation dialog + undo snackbar
                          },
                        ),
                      ).toList(),
                    ),
            ),
          ],
        ),
      ),

      // --- Floating action button to add a new task ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.heading,
        onPressed: () {
          _addNewTask();
        },
        child: const Icon(Icons.add, color: Colors.white),
      )

    );
  }

  Widget _buildHeader(BuildContext context) {
    final today = MaterialLocalizations.of(context)
        .formatFullDate(DateTime.now())
        .toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                color: AppColors.subtext,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          "What's Brewing?",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: AppColors.heading,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          'Let\'s get things done!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.subtext,
              ),
        ),
      ],
    );
  }
}