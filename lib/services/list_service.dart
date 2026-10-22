import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_list.dart';
import 'auth_service.dart';

// a user-facing erro with a message that is safe to show in the UI
class ListException implements Exception {
  final String message;
  const ListException(this.message);

  @override
  String toString() => message;
}

class ListService {
  // firestore instance reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // shortcut getter for the 'lists' collection
  CollectionReference<Map<String, dynamic>> get _lists =>
      _firestore.collection('lists');

  // gets the current authenticated user's ID or throws if not signed in
  String get _currentUid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return user.uid;
  }

  // every collab list the user belongs to (owned or added to).
  // lists whose memberIds do not contain this uid are never returned
  Stream<List<TaskList>> getMyLists(String uid) {
    return _lists
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      // map firestore documents to tasklist objects
      final lists = snapshot.docs
          .map((doc) => TaskList.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      // sort lists chronologically by creation date
      lists.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return lists;
    });
  }

  // creates a new task list with the current user as owner and initial member
  Future<TaskList> createList(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ListException('Enter a name for the list.');
    }

    final uid = _currentUid;
    // auto generates a new firestore document id
    final ref = _lists.doc();  
    final list = TaskList(
      id: ref.id,
      name: trimmed,
      ownerId: uid,
      memberIds: [uid], // the owner is always a member
      createdAt: DateTime.now(),
    );
    // saves the list object to firestore
    await ref.set(list.toMap());
    return list;
  }


}