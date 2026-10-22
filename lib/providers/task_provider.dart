import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import '../services/list_service.dart';
import '../services/task_service.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ChangeNotifier is Flutter's built-in "observable" class.
// Whenever we call notifyListeners(), every widget listening to this
// provider automatically rebuilds with the latest data — that's the
// core mechanic behind the Provider package.
class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final ListService _listService = ListService(); 

  // UID of the signed-in user (null when signed out).
  String? _uid;

  // --- Raw data from Firestore ---
  // This is the FULL list of tasks, unfiltered. We keep it separate
  // from the filtered/sorted list so filters can be changed instantly
  // without needing to re-fetch from Firestore.
  List<Task> _allTasks = [];

  // True until the first batch of tasks arrives from Firestore.
  // The task list screen shows  a spinner while this is true

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // --- collaborative lists ---
  // Every collaborative list the user belongs to (owned or added to).
  List<TaskList> _lists = [];
  List<TaskList> get lists => List.unmodifiable(_lists);

  // kPersonalListId = Personal list, otherwise a collaborative list's id.
  String _selectedListId = kPersonalListId;
  String get selectedListId => _selectedListId;
  bool get isPersonalSelected => _selectedListId == kPersonalListId;

  // The selected collaborative list, or null while Personal is selected.
  TaskList? get selectedList {
    for (final list in _lists) {
      if (list.id == _selectedListId) return list;
    }
    return null;
  }

  // Only the owner of a collaborative list may add members.
  bool get canManageMembers {
    final list = selectedList;
    return list != null && list.ownerId == _uid;
  }

  // Holds the subscription to the Firestore stream so we can cancel
  // it later (in dispose()) and avoid memory leaks.
  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<List<TaskList>>? _listsSubscription; 
  StreamSubscription<User?>? _authSubscription;

  // --- Filter/sort state ---
  TaskTag? selectedTagFilter;
  Priority? selectedPriorityFilter;
  String selectedSort = 'Date added';

  // --- Undo-delete state ---
  // When a task is deleted, we keep it here temporarily so the
  // "Undo" action can restore it before the final delete runs.
  Task? _recentlyDeletedTask;
  Timer? _deleteUndoTimer;
  static const Duration _deleteUndoDuration = Duration(seconds: 4);

  TaskProvider() {
    // Re-run whenever someone signs in or out
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    // Drop the previous user's stream and data immediately
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _listsSubscription?.cancel(); 
    _listsSubscription = null; 
    _allTasks = [];

    // never carry one user's lists or selection over to the next user
    _lists = [];
    _selectedListId = kPersonalListId;
    _uid = user?.uid;

    // don't carry one user's undo state or filters over to the next user
    _deleteUndoTimer?.cancel();
    _recentlyDeletedTask =null;
    selectedTagFilter = null;
    selectedPriorityFilter = null;
    selectedSort = 'Date added';

    _isLoading = user != null;

    // if it is not null, someone just successfully logged in
    if (user != null) {
      // only this user's tasks are requested from firestore
      // subscribing to the new user's tasks
      _listenToLists(user.uid); 
      _subscribeToTasks(user.uid); 
    }

    notifyListeners();
  }

  // streams every collaborative list whose memberIds contains this user.
  // Lists the user was NOT added to are never returned.
  void _listenToLists(String uid) {
    _listsSubscription = _listService.getMyLists(uid).listen(
      (lists) {
        _lists = lists;

        // If the selected list is gone (deleted, or the user was removed),
        // fall back to Personal instead of showing a dead list.
        if (!isPersonalSelected && selectedList == null) {
          _selectedListId = kPersonalListId;
          _subscribeToTasks(uid);
        }

        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('List stream error: $error');
      },
    );
  }

  // (re)subscribes to the tasks of the selected list. This is the
  // same stream code that used to live inside _onAuthChanged, now also
  // used whenever the user switches lists.
  void _subscribeToTasks(String uid) {
    _tasksSubscription?.cancel();
    _allTasks = [];
    _isLoading = true;

    _tasksSubscription =
        _taskService.getTasks(uid, listId: _selectedListId).listen(
      (tasks) {
        _allTasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Task stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // --- switching and managing lists ---

  // Pass kPersonalListId for Personal, or a collaborative list's id.
  void selectList(String listId) {
    final uid = _uid;
    if (uid == null || listId == _selectedListId) return;

    // Ignore ids of lists this user does not belong to.
    if (listId != kPersonalListId && !_lists.any((l) => l.id == listId)) {
      return;
    }

    _selectedListId = listId;
    _subscribeToTasks(uid);
    notifyListeners();
  }

  // Creates a list owned by the current user and switches to it.
  // Throws ListException with a user-friendly message on bad input.
  Future<void> createList(String name) async {
    final list = await _listService.createList(name);

    // The lists stream may not have delivered the new list yet, so add it
    // locally first; otherwise selectList() would ignore the unknown id.
    if (!_lists.any((l) => l.id == list.id)) {
      _lists = [..._lists, list];
    }
    selectList(list.id);
  }

  // Adds a user (by username or email) to the selected list.
  // Throws ListException with a user-friendly message on failure.
  Future<void> addMemberToSelectedList(String identifier) async {
    final list = selectedList;
    if (list == null || !canManageMembers) {
      throw const ListException('Only the list owner can add members.');
    }
    await _listService.addMember(listId: list.id, identifier: identifier);
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

  // tasks always go into the list that is currently selected.
  Future<void> addTask(Task task) async {
    await _taskService.addTask(task.copyWith(listId: _selectedListId));
  }

  // Edits keep the task's own listId (the form passes it through).
  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
  }

  // Toggles isDone for a given task.
  Future<void> toggleTaskDone(Task task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _taskService.updateTask(updated);
  }

  // --- Delete with undo support ---
  // The task is kept in a short grace period so the snackbar can still
  // restore it before the permanent delete is executed.
  Future<void> deleteTask(Task task) async {
    _deleteUndoTimer?.cancel();
    _recentlyDeletedTask = task;
    notifyListeners();

    _deleteUndoTimer = Timer(_deleteUndoDuration, () async {
      if (_recentlyDeletedTask == null || _recentlyDeletedTask!.id != task.id) {
        return;
      }

      await _taskService.deleteTask(task.id);
      _recentlyDeletedTask = null;
      notifyListeners();
    });
  }

  // Called when the user taps "Undo" on the snackbar.
  Future<void> undoDelete() async {
    _deleteUndoTimer?.cancel();

    if (_recentlyDeletedTask != null) {
      final taskToRestore = _recentlyDeletedTask!;
      _recentlyDeletedTask = null;
      notifyListeners();
      await _taskService.restoreTask(taskToRestore);
    }
  }

  // Permanently deletes the task immediately, ignoring the undo window.
  Future<void> forceDelete(Task task) async {
    _deleteUndoTimer?.cancel();
    _recentlyDeletedTask = null;
    notifyListeners();
    await _taskService.deleteTask(task.id);
  }

  // Always cancel stream subscriptions when the provider is disposed,
  // to avoid memory leaks / listening after the widget tree is gone.
  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _listsSubscription?.cancel(); 
    _authSubscription?.cancel();
    _deleteUndoTimer?.cancel();
    super.dispose();
  }
}