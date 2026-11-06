import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/activity.dart';

class ActivityRepository {
  ActivityRepository(this._db);

  final Db _db;

  /// How long read entries are kept before they are cleaned away.
  static const keepReadFor = Duration(days: 90);

  /// [userId]'s inbox, newest first. Read once: the app reads it again on
  /// page changes and refreshes rather than listening, to keep reads low.
  Future<List<Activity>> fetch(String userId) {
    return _db.activity.where('user_id', isEqualTo: userId).get().then((
      snapshot,
    ) {
      final far = DateTime(9999);
      return [
        for (final doc in snapshot.docs)
          Activity.fromMap(doc.data(), id: doc.id),
      ]..sort((a, b) => (b.createdAt ?? far).compareTo(a.createdAt ?? far));
    });
  }

  Future<void> markRead(Iterable<Activity> entries) async {
    final unread = entries.where((a) => !a.read).toList();
    if (unread.isEmpty) return;
    final batch = _db.firestore.batch();
    for (final entry in unread) {
      batch.update(_db.activity.doc(entry.id), {'read': true});
    }
    await batch.commit();
  }

  Future<void> delete(Iterable<Activity> entries) async {
    final batch = _db.firestore.batch();
    for (final entry in entries) {
      batch.delete(_db.activity.doc(entry.id));
    }
    await batch.commit();
  }

  /// Read entries older than [keepReadFor], so the inbox does not grow
  /// forever.
  Iterable<Activity> stale(Iterable<Activity> entries, DateTime now) {
    return entries.where(
      (a) =>
          a.read &&
          a.createdAt != null &&
          now.difference(a.createdAt!) > keepReadFor,
    );
  }
}
