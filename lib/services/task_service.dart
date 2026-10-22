import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';
import '../utils/constants.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tasks';

  // The UID of whoever is signed in right now. 
  // New tasks get this as ownerId.

  // getter that returns a String representing the current user's ID
  String get _currentUid {

    // get the current user instance from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    // verify if a user is actually logged in
    if (user == null) {
      // if null, throw stateerror to stop execution
      throw StateError('No signed-in user.');
    }
    // otherwise, return firebase uid
    return user.uid;
  }

  // Only returns tasks whose ownerId matches the given user.
  // TaskProvider already sorts locally so no order by.

  // Personal: only my own tasks that are in the personal list
  // Collab: every task in that list (the rules check the membership)
  // streams personal tasks or collaborative list tasks in real-time
  Stream<List<Task>> getTasks(
    String ownerId, {
    String listId = kPersonalListId,
  }) {
    // query personal task if matching ID, otherwise query the collab list
    final Query<Map<String, dynamic>> query = listId == kPersonalListId
        ? _firestore
            .collection(_collectionName)
            .where('ownerId', isEqualTo: ownerId)
            .where('listId', isEqualTo: kPersonalListId)
        : _firestore
            .collection(_collectionName)
            .where('listId', isEqualTo: listId);

    // map firestore snapshot documents to a List<Task>
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Future<void> addTask(Task task) async {
    // Let Firestore generate the document ID so it can 
    // never collide with another user's task
    final ref = _firestore.collection(_collectionName).doc();
    final owned = task.copyWith(id: ref.id, ownerId: _currentUid);
    await ref.set(owned.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore
        .collection(_collectionName)
        .doc(task.id)
        .set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }

  Future<void> restoreTask(Task task) async {
    await _firestore
        .collection(_collectionName)
        .doc(task.id)
        .set(task.toMap(), SetOptions(merge: true));
  }
}
