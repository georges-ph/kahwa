import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/app_user.dart';

class UserRepository {
  UserRepository(this._auth, this._storage, this._collections);

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
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

  Future<void> updateProfile(AppUser user) async {
    await _auth.currentUser?.updateDisplayName(user.name);
    await _collections.users.doc(user.id).update({
      'name': user.name,
      'about': user.about,
      'website': user.website,
      'color': user.color.name,
    });
  }

  /// Uploads [bytes] as the profile picture of [userId] and returns its URL.
  Future<String> uploadProfilePicture({
    required String userId,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    final reference = _storage.ref('kahwa/Profile Pictures/$userId.jpg');
    final task = reference.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final subscription = task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    }, onError: (_) {});

    try {
      await task;
    } finally {
      await subscription.cancel();
    }

    final url = await reference.getDownloadURL();
    await _auth.currentUser?.updatePhotoURL(url);
    await _collections.users.doc(userId).update({'image': url});
    return url;
  }
}
