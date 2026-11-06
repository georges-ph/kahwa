import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/activity.dart';
import 'package:kahwa/models/profile.dart';

/// The username asked for belongs to someone else.
class UsernameTakenException implements Exception {
  const UsernameTakenException();
}

class ProfileRepository {
  ProfileRepository(this._db);

  final Db _db;

  Future<Profile?> get(String id) async {
    final doc = await _db.profiles.doc(id).get();
    final data = doc.data();
    return data == null ? null : Profile.fromMap(data, id: doc.id);
  }

  /// Profiles of [ids], in no particular order. Missing ones are left out.
  Future<List<Profile>> getMany(Iterable<String> ids) async {
    if (ids.isEmpty) return [];
    final docs = await _db.getByIds(_db.profiles, ids);
    return [for (final doc in docs) Profile.fromMap(doc.data(), id: doc.id)];
  }

  /// Every page that accepts kahwas, for Explore. kahwa expects a handful
  /// of creators, so they are all read and sorted on the device.
  Future<List<Profile>> creators() async {
    final snapshot = await _db.profiles
        .where('is_creator', isEqualTo: true)
        .limit(500)
        .get();
    return [
      for (final doc in snapshot.docs) Profile.fromMap(doc.data(), id: doc.id),
    ];
  }

  /// The creators [userId] is a fan of.
  Future<List<Profile>> fannedBy(String userId) async {
    final snapshot = await _db.profiles
        .where('fan_ids', arrayContains: userId)
        .get();
    return [
      for (final doc in snapshot.docs) Profile.fromMap(doc.data(), id: doc.id),
    ];
  }

  /// Id of the user who holds [username], if anyone.
  Future<String?> idOfUsername(String username) async {
    final doc = await _db.usernames.doc(username).get();
    return doc.data()?['user_id'] as String?;
  }

  /// Saves what the owner edited. A new username is reserved in the same
  /// write, and the old one released, so two pages never share one.
  ///
  /// Throws [UsernameTakenException] when someone else holds the username.
  Future<void> save(Profile profile, {String? previousUsername}) async {
    final username = profile.username;
    final batch = _db.firestore.batch();
    if (username != previousUsername) {
      if (username != null) {
        final holder = await idOfUsername(username);
        if (holder != null && holder != profile.id) {
          throw const UsernameTakenException();
        }
        if (holder == null) {
          batch.set(_db.usernames.doc(username), {'user_id': profile.id});
        }
      }
      if (previousUsername != null) {
        batch.delete(_db.usernames.doc(previousUsername));
      }
    }
    batch.update(_db.profiles.doc(profile.id), profile.toEditableMap());
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // Taken by someone between the check and the write.
      if (e.code == 'permission-denied' && username != previousUsername) {
        throw const UsernameTakenException();
      }
      rethrow;
    }
  }

  /// The inbox entry telling [creatorId] that [fanId] became a fan. Always
  /// the same, so it can be taken back when they stop being one.
  static String fanEntryId(String creatorId, String fanId) {
    return 'fan_${creatorId}_$fanId';
  }

  /// Makes [me] a fan of [creatorId], or stops it. Becoming a fan tells the
  /// creator in their inbox; stopping takes that back.
  Future<void> setFan({
    required String creatorId,
    required Profile me,
    required bool fan,
  }) async {
    final ref = _db.profiles.doc(creatorId);
    final entry = _db.activity.doc(fanEntryId(creatorId, me.id));
    final batch = _db.firestore.batch();
    if (!fan) {
      batch
        ..update(ref, {
          'fan_ids': FieldValue.arrayRemove([me.id]),
        })
        ..delete(entry);
    } else {
      batch
        ..update(ref, {
          'fan_ids': FieldValue.arrayUnion([me.id]),
        })
        ..set(
          entry,
          Activity.newMap(
            userId: creatorId,
            kind: ActivityKind.fan,
            actorId: me.id,
            actorName: me.name,
            ref: me.id,
          ),
        );
    }
    await batch.commit();
  }
}
