import 'package:hive_ce/hive.dart';

import 'objective_id.dart';
import 'tip/tip_id.dart';

part 'objective_state.g.dart';

/// Per-player bookkeeping of the objectives: those completed, whether the
/// tutorial guides the player, whether tip cards show up and those seen.
@HiveType(typeId: 54)
class ObjectiveState {
  /// Objectives completed, in the order they were; a completion stays,
  /// whatever happens to its progress afterwards.
  @HiveField(0)
  final List<ObjectiveId> completed;

  /// Whether the guide leads the player: chosen when the game started,
  /// switched in the settings afterwards.
  @HiveField(1)
  bool tutorialEnabled;

  /// Whether a tip card explains each screen the first time it opens; off
  /// for the games saved before the tips.
  @HiveField(2, defaultValue: false)
  bool tipsEnabled;

  /// Tip cards already opened, in the order they were; none for the games
  /// saved before the tip cards.
  @HiveField(3)
  final List<TipId> seenTips;

  ObjectiveState({
    List<ObjectiveId>? completed,
    this.tutorialEnabled = false,
    this.tipsEnabled = false,
    List<TipId>? seenTips,
  }) : completed = completed ?? [],
       seenTips = seenTips ?? [];

  bool isCompleted(ObjectiveId id) => completed.contains(id);

  /// Records [id] as completed, once.
  void complete(ObjectiveId id) {
    if (!isCompleted(id)) completed.add(id);
  }

  bool hasSeen(TipId id) => seenTips.contains(id);

  /// Records the tip [id] as seen, once.
  void markSeen(TipId id) {
    if (!hasSeen(id)) seenTips.add(id);
  }
}
