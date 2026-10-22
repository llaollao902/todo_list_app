import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/filter_sort_sheet.dart'; 
import '../widgets/list_header.dart';
import '../widgets/task_tile.dart';
import 'form_task_screen.dart';
import 'profile_screen.dart';
import '../widgets/empty_state.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/undo_snackbar.dart';
import '../services/list_service.dart';
import '../widgets/list_switcher.dart';
import '../widgets/new_list_dialog.dart';
import '../widgets/add_member_dialog.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
    Future<void> _openFilterSheet() async {
    final provider = context.read<TaskProvider>();

    final result = await FilterSortSheet.show(
      context,
      tag: provider.selectedTagFilter,
      priority: provider.selectedPriorityFilter,
      sort: provider.selectedSort,
    );

    if (result == null || !mounted) return;

    provider.setTagFilter(result.tag);
    provider.setPriorityFilter(result.priority);
    provider.setSort(result.sort);
  }

  int _activeFilterCount(TaskProvider provider) {
    var count = 0;
    if (provider.selectedTagFilter != null) count++;
    if (provider.selectedPriorityFilter != null) count++;
    if (provider.selectedSort != 'Date added') count++;
    return count;
  }

  // updates the selected task list through the TaskProvider
  void _onListSelected(String listId) {
    context.read<TaskProvider>().selectList(listId);
  }

  // prompts the user for a list name and creates the list
  Future<void> _createList() async {
    final name = await NewListDialog.show(context);

    // stop if the dialog was canceled or the widget is no longer active
    if (name == null || !mounted) return;

    try {
      await context.read<TaskProvider>().createList(name);
    } on ListException catch (e) {
      // show a specific error message for expected list related errors
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      // show a fallback message for unexpected errors
      if (!mounted) return;
      _showMessage('Unable to create the list. Please try again.');
    }
  }

  // prompts for a username/email and adds that user to the selected list
  Future<void> _addMember() async {
    final provider = context.read<TaskProvider>();
    final listName = provider.selectedList?.name ?? 'this list';

    final identifier = await AddMemberDialog.show(context, listName: listName);
    if (identifier == null || !mounted) return;

    try {
      await provider.addMemberToSelectedList(identifier);
      if (!mounted) return;
      _showMessage('Added to "$listName".');
    } on ListException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to add that member. Please try again.');
    }
  }

  // displays a message at the bottom of the screen using a snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  Future<void> _editTask(Task task) async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => FormTaskScreen(task: task)),
    );

    if (updatedTask != null && mounted) {
      await context.read<TaskProvider>().updateTask(updatedTask);
    }
  }

  // Deletes a task after confirming with the user, and shows an undo snackbar.
  Future<void> _deleteTask(Task task) async {
    final confirmed = await DeleteConfirmDialog.show(context, task.title);

    if (!confirmed || !mounted) {
      return;
    }

    final provider = context.read<TaskProvider>();
    await provider.deleteTask(task);

    if (!mounted) {
      return;
    }

    // All the snackbar UI/config now lives in UndoSnackbar — this
    // screen just decides WHEN to show it and WHAT happens on undo.
    UndoSnackbar.show(
      context,
      message: '"${task.title}" deleted',
      onUndo: () => provider.undoDelete(),
      onDelete: () => provider.forceDelete(task),
    );
  }

  Future<void> _logOut() async {
    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out. Please try again.')),
      );
    }
  }

  void _openProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  // Builds the main UI of the task list screen, including the header, filter/sort bar, and the list of tasks.
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
                  ListSwitcher(
                    lists: provider.lists,
                    selectedListId: provider.selectedListId,
                    taskCounts: provider.taskCounts,
                    onSelected: _onListSelected,
                    onNewList: _createList,
                    onAddMember:
                        provider.canManageMembers ? _addMember : null,
                  ),
                  const SizedBox(height: 15),

                  // "Your list · N" / "N completed" on the left,
                  // Filter button on the right.
                  ListHeader(
                    totalCount: tasks.length,
                    completedCount: completedCount,
                    activeFilterCount: _activeFilterCount(provider),
                    onFilterTap: _openFilterSheet,
                  ),
                ],
              ),
            ),

            // Scrollable task area
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tasks.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                          alignment: Alignment(0.0, -0.4),
                          child: EmptyState(),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        children: tasks
                            .map(
                              (task) => TaskTile(
                                task: task,
                                onToggleDone: () => _toggleTaskDone(task.id),
                                onEdit: () => _editTask(task),
                                onDelete: () => _deleteTask(task),
                              ),
                            )
                            .toList(),
                      ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _logOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log Out'),
                style: TextButton.styleFrom(foregroundColor: AppColors.heading),
              ),
              FloatingActionButton(
                backgroundColor: AppColors.heading,
                onPressed: _addNewTask,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final today = MaterialLocalizations.of(context)
        .formatFullDate(DateTime.now())
        .toUpperCase();
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'there';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hello, $userName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Georgia',
                                color: AppColors.heading,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: _openProfile,
                        tooltip: 'Profile settings',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.heading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Let\'s get things done!',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.subtext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
