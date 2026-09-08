import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/constants.dart';

// ChangeNotifier is Flutter's built-in "observable" class.
// Whenever we call notifyListeners(), every widget listening to this
// provider automatically rebuilds with the latest data — that's the
// core mechanic behind the Provider package.
class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  // --- Raw data from Firestore ---
  // This is the FULL list of tasks, unfiltered. We keep it separate
  // from the filtered/sorted list so filters can be changed instantly
  // without needing to re-fetch from Firestore.
  List<Task> _allTasks = [];

  // Holds the subscription to the Firestore stream so we can cancel
  // it later (in dispose()) and avoid memory leaks.
  StreamSubscription<List<Task>>? _subscription;

  // --- Filter/sort state ---
  TaskTag? selectedTagFilter;
  Priority? selectedPriorityFilter;
  String selectedSort = 'Date added';

  // --- Undo-delete state ---
  // When a task is deleted, we hold onto it here temporarily so the
  // "Undo" snackbar can restore it if tapped in time.
  Task? _recentlyDeletedTask;

  TaskProvider() {
    // Start listening to Firestore the moment this provider is created.
    _listenToTasks();
  }

  void _listenToTasks() {
    // .listen() runs this callback EVERY time Firestore's data changes
    // — not just once. That's what makes the UI "live": add a task from
    // another device, and it appears here automatically.
    _subscription = _taskService.getTasks().listen((tasks) {
      _allTasks = tasks;
      notifyListeners(); // tells every listening widget to rebuild
    });
  }

  // --- Public getter: filtered + sorted list ---
  // Widgets read THIS, never _allTasks directly, so filtering/sorting
  // logic lives in exactly one place.
  List<Task> get tasks {
    List<Task> result = List.from(_allTasks);

    // Apply tag filter, if one is selected.
    if (selectedTagFilter != null) {
      result = result.where((t) => t.tag == selectedTagFilter).toList();
    }

    // Apply priority filter, if one is selected.
    if (selectedPriorityFilter != null) {
      result = result.where((t) => t.priority == selectedPriorityFilter).toList();
    }

    // Apply sorting based on the selected option.
    switch (selectedSort) {
      case 'Due date':
        result.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
        break;
      case 'Priority':
        // High should appear before Medium before Low.
        // Priority enum order is low(0), medium(1), high(2), so we
        // reverse the comparison to get high-first.
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'Tag':
        result.sort((a, b) => a.tag.label.compareTo(b.tag.label));
        break;
      case 'Date added':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
        break;
    }

    return result;
  }

  // Count of completed tasks, for the ListHeader.
  int get completedCount => _allTasks.where((t) => t.isDone).length;

  // Total task count (unfiltered — matches "Your list · N" in mockup,
  // which counts ALL tasks, not just the filtered view).
  int get totalCount => _allTasks.length;

  // --- Filter/sort setters ---
  // Each setter updates state AND calls notifyListeners() so the UI
  // rebuilds with the new filtered/sorted list immediately.
  void setTagFilter(TaskTag? tag) {
    selectedTagFilter = tag;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSort(String sort) {
    selectedSort = sort;
    notifyListeners();
  }

  // --- CRUD operations ---
  // These just delegate to TaskService. We don't need to manually
  // update _allTasks or call notifyListeners() after these — the
  // Firestore stream listener above does that automatically once
  // the change round-trips through the database.

  Future<void> addTask(Task task) async {
    
  }

  Future<void> updateTask(Task task) async {}

  // --- Delete with undo support ---
  Future<void> deleteTask(Task task) async {}

  // Called when the user taps "Undo" on the snackbar.
  Future<void> undoDelete() async {}

  // Always cancel stream subscriptions when the provider is disposed,
  // to avoid memory leaks / listening after the widget tree is gone.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}