import '../models/task.dart';
import '../utils/constants.dart';

// Temporary hardcoded task list, used only during UI development.
// This lets us build and preview screens before Firebase is wired up.
//
// Once TaskService + TaskProvider are ready, this file becomes
// unnecessary and can be deleted — task_list_screen.dart will pull
// its data from a live Firestore stream instead.
List<Task> getDummyTasks() {
  return [
    Task(
      id: '1',
      title: 'Finish CMSC 124 Lab',
      dueDateTime: DateTime(2026, 9, 10, 18, 30),
      priority: Priority.high,
      tag: TaskTag.school,
      isDone: false,
    ),
    Task(
      id: '2',
      title: 'Buy groceries for the week',
      dueDateTime: DateTime(2026, 9, 11, 16, 0),
      priority: Priority.medium,
      tag: TaskTag.personal,
      isDone: false,
    ),
    Task(
      id: '3',
      title: 'Review CMSC 141',
      dueDateTime: DateTime(2026, 9, 12, 20, 0),
      priority: Priority.low,
      tag: TaskTag.school,
      isDone: true, // completed — should show strikethrough
    ),
    Task(
      id: '4',
      title: 'Meditate',
      dueDateTime: DateTime(2026, 9, 13, 11, 0),
      priority: Priority.high,
      tag: TaskTag.personal,
      isDone: false,
    ),
  ];
}