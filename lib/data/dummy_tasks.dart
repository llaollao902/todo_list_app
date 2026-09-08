import '../models/task.dart';
import '../utils/constants.dart';

// Temporary hardcoded task list, used only during UI development.
// This lets us build and preview screens before Firebase is wired up.
//
// Once TaskService + TaskProvider are ready, this file becomes
// unnecessary and can be deleted — task_list_screen.dart will pull
// its data from a live Firestore stream instead.
List<Task> getDummyTasks() {
  return [];
}