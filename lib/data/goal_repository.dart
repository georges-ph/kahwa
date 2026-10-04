import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/goal.dart';

class GoalRepository {
  GoalRepository(this._collections);

  final Collections _collections;

  /// The active goal of [creatorId], if they have one.
  Future<Goal?> getGoal(String creatorId) async {
    final document = await _collections.goals.doc(creatorId).get();
    final data = document.data();
    return data == null ? null : Goal.fromMap(data);
  }

  Future<void> saveGoal(Goal goal) {
    return _collections.goals.doc(goal.id).set(goal.toMap());
  }

  /// Removes the active goal and keeps a copy in the archive of the creator.
  Future<void> archiveGoal(Goal goal) {
    final batch = _collections.firestore.batch();
    batch.delete(_collections.goals.doc(goal.id));
    batch.set(_collections.archivedGoals(goal.id).doc(), goal.toMap());
    return batch.commit();
  }
}
