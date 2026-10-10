import 'package:hive_ce/hive.dart';

import 'objective_id.dart';

part 'objective_state.g.dart';

/// Per-player bookkeeping of the objectives: those completed, and whether
/// the tutorial guides the player.
@HiveType(typeId: 54)
class ObjectiveState {
  /// Objectives completed, in the order they were; a completion stays,
  /// whatever happens to its progress afterwards.
  @HiveField(0)
  final List<ObjectiveId> completed;

  /// Whether the player chose the tutorial when the game started.
  @HiveField(1)
  bool tutorialEnabled;

  ObjectiveState({List<ObjectiveId>? completed, this.tutorialEnabled = false})
    : completed = completed ?? [];

  bool isCompleted(ObjectiveId id) => completed.contains(id);

  /// Records [id] as completed, once.
  void complete(ObjectiveId id) {
    if (!isCompleted(id)) completed.add(id);
  }
}
