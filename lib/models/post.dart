import 'package:cloud_firestore/cloud_firestore.dart';

/// An update a creator shares on their page.
///
/// A members-only post keeps its text in a `PostBodies` document, which only
/// the creator and paying members can read; the public document only says a
/// post exists.
class Post {
  const Post({
    required this.id,
    required this.creatorId,
    this.text = '',
    this.membersOnly = false,
    this.likedBy = const [],
    this.createdAt,
    this.editedAt,
    this.locked = false,
  });

  static const maxLength = 2000;

  final String id;
  final String creatorId;
  final String text;
  final bool membersOnly;
  final List<String> likedBy;
  final DateTime? createdAt;
  final DateTime? editedAt;

  /// True when the post is for members and the viewer cannot read it.
  final bool locked;

  int get likes => likedBy.length;

  bool isLikedBy(String? userId) => userId != null && likedBy.contains(userId);

  Post withBody(String? body) {
    return Post(
      id: id,
      creatorId: creatorId,
      text: body ?? '',
      membersOnly: membersOnly,
      likedBy: likedBy,
      createdAt: createdAt,
      editedAt: editedAt,
      locked: body == null,
    );
  }

  Post toggledLike(String userId) {
    return Post(
      id: id,
      creatorId: creatorId,
      text: text,
      membersOnly: membersOnly,
      likedBy: isLikedBy(userId)
          ? [...likedBy.where((id) => id != userId)]
          : [...likedBy, userId],
      createdAt: createdAt,
      editedAt: editedAt,
      locked: locked,
    );
  }

  factory Post.fromMap(Map<String, dynamic> map, {required String id}) {
    return Post(
      id: id,
      creatorId: map['creator_id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      membersOnly: map['members_only'] == true,
      likedBy: List<String>.from(map['liked_by'] ?? const []),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      editedAt: (map['edited_at'] as Timestamp?)?.toDate(),
    );
  }
}
