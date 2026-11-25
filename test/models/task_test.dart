import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/models/task.dart';
import 'package:todo_list_app/utils/constants.dart';

void main() {
  group('Task.copyWith', () {
    test('preserves the list ID when updating other fields', () {
      final task = Task(
        id: 'task-1',
        ownerId: 'user-1',
        listId: kPersonalListId,
        title: 'Buy groceries',
        dueDateTime: DateTime(2026, 10, 23),
        priority: Priority.medium,
        tag: TaskTag.personal,
      );

      final copied = task.copyWith(id: 'firestore-id', ownerId: 'user-1');

      expect(copied.id, 'firestore-id');
      expect(copied.listId, kPersonalListId);
      expect(copied.title, 'Buy groceries');
    });
  });
}
