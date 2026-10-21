import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';

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

  Stream<List<Task>> getTasks() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> addTask(Task task) async {
    await _firestore
        .collection(_collectionName)
        .doc(task.id)
        .set(task.toMap(), SetOptions(merge: true));
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
