import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kahwa/core/refresh.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/app_user.dart';

class UserRepository {
  UserRepository(this._auth, this._collections);

  final FirebaseAuth _auth;
  final Collections _collections;

  Future<AppUser?> getUser(String id) async {
    final document = await _collections.users.doc(id).get();
    final data = document.data();
    return data == null ? null : AppUser.fromMap(data);
  }

  /// Users for [ids], in the same order. Unknown ids are skipped.
  Future<List<AppUser>> getUsers(Iterable<String> ids) async {
    final users = await Future.wait(ids.toSet().map(getUser));
    final byId = {for (final user in users.nonNulls) user.id: user};
    return [for (final id in ids) ?byId[id]];
  }

  Future<List<AppUser>> getCreatorsFollowedBy(String userId) async {
    final query = await _collections.users
        .where('fans', arrayContains: userId)
        .get();
    return [for (final doc in query.docs) AppUser.fromMap(doc.data())];
  }

  Future<void> setFan({
    required String creatorId,
    required String userId,
    required bool isFan,
  }) {
    return _collections.users.doc(creatorId).update({
      'fans': isFan
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  /// Id of the creator who owns [username], if anyone does.
  Future<String?> getUserIdByUsername(String username) async {
    final document = await _collections.usernames.doc(username).get();
    return document.data()?['user_id'];
  }

  /// Gives [userId] the handle [username], releasing [previous] if they had
  /// one. Pass null to only release it. Returns false when it is taken.
  Future<bool> setUsername({
    required String userId,
    required String? username,
    required String? previous,
  }) async {
    if (username == previous) return true;
    if (username != null && await getUserIdByUsername(username) != null) {
      return false;
    }

    final batch = _collections.firestore.batch();
    if (previous != null) batch.delete(_collections.usernames.doc(previous));
    if (username != null) {
      batch.set(_collections.usernames.doc(username), {'user_id': userId});
    }
    batch.update(_collections.users.doc(userId), {
      'username': username,
      // Pages are public. Older accounts stored the email here, drop it.
      'email': FieldValue.delete(),
    });
    try {
      await batch.commit();
      notifyDataChanged();
      return true;
    } on FirebaseException catch (e) {
      // Someone else took it between the check and the write.
      if (e.code == 'permission-denied') return false;
      rethrow;
    }
  }

  Future<void> updateProfile(AppUser user) async {
    await _auth.currentUser?.updateDisplayName(user.name);
    await _collections.users.doc(user.id).update({
      'name': user.name,
      'about': user.about,
      'website': user.website,
      'color': user.color.name,
      // Pages are public. Older accounts stored the email here, drop it.
      'email': FieldValue.delete(),
    });
    notifyDataChanged();
  }
}
