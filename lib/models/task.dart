import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class Task {
  final String id;
  final String ownerId; // uid for the user who created the task
  final String listId; // kPersonalListId (collab list id)
  final String title;
  final DateTime dueDateTime;
  final DateTime createdAt;
  final Priority priority;
  final TaskTag tag;
  final bool isDone;

  Task({
    required this.id,
    required this.ownerId,
    this.listId = kPersonalListId,
    required this.title,
    required this.dueDateTime,
    DateTime? createdAt,
    required this.priority,
    required this.tag,
    this.isDone = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromMap(Map<String, dynamic> map) {
    final rawPriority = map['priority'];
    final rawTag = map['tag'];

    return Task(
      id: map['id']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      listId: map['listId']?.toString() ?? kPersonalListId, 
      title: map['title']?.toString() ?? '',
      dueDateTime: (map['dueDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: Priority.values.firstWhere(
        (value) => value.name == rawPriority,
        orElse: () => Priority.medium,
      ),
      tag: TaskTag.values.firstWhere(
        (value) => value.name == rawTag,
        orElse: () => TaskTag.personal,
      ),
      isDone: map['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'listId': listId,
      'title': title,
      'dueDateTime': Timestamp.fromDate(dueDateTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority.name,
      'tag': tag.name,
      'isDone': isDone,
    };
  }

  // Helper method to update task properties (immutability)
  Task copyWith({
    String? id,
    String? ownerId,
    String? listId,
    String? title,
    DateTime? dueDateTime,
    DateTime? createdAt,
    Priority? priority,
    TaskTag? tag,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      listId: listId ?? this.title,
      title: title ?? this.title,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      isDone: isDone ?? this.isDone,
    );
  }
}