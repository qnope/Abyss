import '../../event/event_state.dart';
import '../../event/event_turn_outcome.dart';
import 'temporary_objective.dart';
import 'temporary_objective_end.dart';

/// One event able to set a temporary objective: when it is active, read
/// from the saved [EventState], and how it ends, read from what the
/// events did while a turn ended.
abstract class TemporaryObjectiveSource {
  const TemporaryObjectiveSource();

  /// The objective active during [turn], or `null`.
  TemporaryObjective? activeIn(EventState state, int turn);

  /// The objective that ended at the end of the turn of [outcome], or
  /// `null`.
  TemporaryObjectiveEnd? endedBy(EventTurnOutcome outcome);
}
