import 'temporary_objective_kind.dart';

/// An objective an event sets for a while, outside the catalog and with
/// no reward of its own: what the event gives is the reward.
class TemporaryObjective {
  final TemporaryObjectiveKind kind;

  /// Shown to the player, in French.
  final String title;

  /// Last turn, inclusive, the objective can be reached.
  final int lastTurn;

  const TemporaryObjective({
    required this.kind,
    required this.title,
    required this.lastTurn,
  });

  @override
  bool operator ==(Object other) =>
      other is TemporaryObjective &&
      other.kind == kind &&
      other.title == title &&
      other.lastTurn == lastTurn;

  @override
  int get hashCode => Object.hash(kind, title, lastTurn);
}
