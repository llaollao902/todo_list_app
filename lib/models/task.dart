import '../utils/constants.dart';

class Task {
  final String id;
  final String title;
  final DateTime dueDateTime;
  final Priority priority;
  final TaskTag tag;
  final bool isDone;

  const Task({
    required this.id,
    required this.title,
    required this.dueDateTime,
    required this.priority,
    required this.tag,
    this.isDone = false,
  });

  // Helper method to update task properties (immutability)
  Task copyWith({
    String? id,
    String? title,
    DateTime? dueDateTime,
    Priority? priority,
    TaskTag? tag,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      isDone: isDone ?? this.isDone,
    );
  }
}