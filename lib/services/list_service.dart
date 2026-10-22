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

  // Owner-only (enforced by the rules): add a user by username or email.
  // adds a member to a specific task list using their identifier (email/username)
  Future<void> addMember({
    required String listId,
    required String identifier,
  }) async {
    // resolve the given identifier to a unique user ID (UID)
    final uid = await _resolveUid(identifier);

    final ref = _lists.doc(listId);
    final snapshot = await ref.get();
    final members = List<String>.from(snapshot.data()?['memberIds'] ?? const []);

    // check if the user is already a member of the list
    if (members.contains(uid)) {
      throw const ListException('That user is already in this list.');
    }

    // atomically add the new user's uid to the memberIds array in firestore
    await ref.update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
  }


}