import 'temporary_objective_kind.dart';

/// An objective an event sets for a while, outside the catalog and with
/// no reward of its own: what the event gives is the reward. The
/// presentation words it after its [kind] and [lastTurn].
class TemporaryObjective {
  final TemporaryObjectiveKind kind;

  /// Last turn, inclusive, the objective can be reached.
  final int lastTurn;

  const TemporaryObjective({required this.kind, required this.lastTurn});

  @override
  bool operator ==(Object other) =>
      other is TemporaryObjective &&
      other.kind == kind &&
      other.lastTurn == lastTurn;

  @override
  int get hashCode => Object.hash(kind, lastTurn);

  @override
  String toString() => 'TemporaryObjective(${kind.name}, $lastTurn)';
}
