class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _allTasks = [];
}

StreamSubscription<List<Task>>? _subscription;

TaskProvider() {
  _listenToTasks();
}

void _listenToTasks() {
  _subscription = _taskService.getTasks().listen((tasks) {
    _allTasks = tasks;
    notifyListeners();
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}