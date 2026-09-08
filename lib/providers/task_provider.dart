class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _allTasks = [];
}