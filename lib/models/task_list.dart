import 'package:cloud_firestore/cloud_firestore.dart';

// A collab list. the owner is always inside memberIds
class TaskList {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;

  const TaskList({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
  });

  // factory constructor to deserialize raw firestore doc data(map)
  // into a task list object.
  // handles null checks safely with fallback defaults
  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',

      // safely casts the dynamic list from Firestore to a List<String>
      memberIds: List<String>.from(map['memberIds'] ?? const []),

      // Converts Firestore's native Timestamp type 
      // to a Dart DateTime (defaults to current time if null)
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // converts this tasklist instance into a map structure
  // suitable for saving/writing directly to cloud firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      // Converts Dart DateTime back to Firestore's Timestamp format before storing
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}