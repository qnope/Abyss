import 'temporary_objective.dart';

/// How a temporary objective ended.
enum TemporaryObjectiveOutcome {
  /// Reached in time.
  done,

  /// Its last turn went by before it was reached.
  expired,

  /// Lost for good, like a fight lost.
  failed,
}

/// A temporary objective that ended at the end of a turn.
class TemporaryObjectiveEnd {
  final TemporaryObjective objective;
  final TemporaryObjectiveOutcome outcome;

  const TemporaryObjectiveEnd({required this.objective, required this.outcome});

  bool get isDone => outcome == TemporaryObjectiveOutcome.done;
}
