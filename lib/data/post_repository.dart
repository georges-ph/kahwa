import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/post.dart';

class PostRepository {
  PostRepository(this._db);

  final Db _db;

  /// Posts of [creatorId], newest first. Members-only posts are locked
  /// unless [viewerId] is the creator or a paying member.
  Future<List<Post>> postsOf(String creatorId, {String? viewerId}) {
    return _postsWhere(
      _db.posts.where('creator_id', isEqualTo: creatorId),
      viewerId: viewerId,
    );
  }

  /// Posts of the creators [userId] follows, newest first, for Home.
  Future<List<Post>> feed(List<String> creatorIds, {String? viewerId}) async {
    if (creatorIds.isEmpty) return [];
    final ids = creatorIds.take(30).toList();
    final posts = await _postsWhere(
      _db.posts.where('creator_id', whereIn: ids).limit(100),
      viewerId: viewerId,
    );
    return posts;
  }

  Future<List<Post>> _postsWhere(
    Query<Json> query, {
    required String? viewerId,
  }) async {
    final snapshot = await query.get();
    final posts = [
      for (final doc in snapshot.docs) Post.fromMap(doc.data(), id: doc.id),
    ];
    final opened = await Future.wait([
      for (final post in posts)
        post.membersOnly ? _open(post, viewerId) : Future.value(post),
    ]);
    final far = DateTime(9999);
    return opened
      ..sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
  }

  /// [post] with its text, when the rules let [viewerId] read it.
  Future<Post> _open(Post post, String? viewerId) async {
    if (viewerId == null) return post.withBody(null);
    try {
      final doc = await _db.postBodies.doc(post.id).get();
      return post.withBody(doc.data()?['text'] as String? ?? '');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return post.withBody(null);
      rethrow;
    }
  }

  Future<void> create({
    required String creatorId,
    required String text,
    required bool membersOnly,
  }) async {
    final ref = _db.posts.doc();
    final batch = _db.firestore.batch()
      ..set(ref, {
        'creator_id': creatorId,
        'text': membersOnly ? '' : text.trim(),
        'members_only': membersOnly,
        'liked_by': <String>[],
        'created_at': FieldValue.serverTimestamp(),
      });
    if (membersOnly) {
      batch.set(_db.postBodies.doc(ref.id), {
        'creator_id': creatorId,
        'text': text.trim(),
      });
    }
    await batch.commit();
  }

  /// Changes the text of [post], and who can read it: the text of a
  /// members-only post is kept apart from the post itself.
  Future<void> edit(Post post, String text, {required bool membersOnly}) async {
    final body = _db.postBodies.doc(post.id);
    final batch = _db.firestore.batch()
      ..update(_db.posts.doc(post.id), {
        'text': membersOnly ? '' : text.trim(),
        'members_only': membersOnly,
        'edited_at': FieldValue.serverTimestamp(),
      });
    if (membersOnly) {
      batch.set(body, {'creator_id': post.creatorId, 'text': text.trim()});
    } else if (post.membersOnly) {
      batch.delete(body);
    }
    await batch.commit();
  }

  Future<void> delete(Post post) async {
    final batch = _db.firestore.batch()..delete(_db.posts.doc(post.id));
    if (post.membersOnly) batch.delete(_db.postBodies.doc(post.id));
    await batch.commit();
  }

  Future<void> setLike(Post post, String userId, {required bool like}) {
    return _db.posts.doc(post.id).update({
      'liked_by': like
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }
}
