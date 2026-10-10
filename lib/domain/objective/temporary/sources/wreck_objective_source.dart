import '../../../event/event_state.dart';
import '../../../event/event_turn_outcome.dart';
import '../temporary_objective.dart';
import '../temporary_objective_end.dart';
import '../temporary_objective_kind.dart';
import '../temporary_objective_source.dart';

/// « Fouille l'épave d'ici la fin du tour N » while a wreck lies on the map:
/// done once searched, expired once sunk.
class WreckObjectiveSource extends TemporaryObjectiveSource {
  const WreckObjectiveSource();

  @override
  TemporaryObjective? activeIn(EventState state, int turn) {
    final int? until = state.wreckUntilTurn;
    if (state.wreckPosition == null || until == null || turn > until) {
      return null;
    }
    return _objective(until);
  }

  @override
  TemporaryObjectiveEnd? endedBy(EventTurnOutcome outcome) {
    final wreck = outcome.wreck;
    if (wreck == null) return null;
    return TemporaryObjectiveEnd(
      objective: _objective(wreck.untilTurn),
      outcome:
          wreck.searched
              ? TemporaryObjectiveOutcome.done
              : TemporaryObjectiveOutcome.expired,
    );
  }

  static TemporaryObjective _objective(int until) => TemporaryObjective(
    kind: TemporaryObjectiveKind.wreck,
    title: "Fouille l'épave d'ici la fin du tour $until",
    lastTurn: until,
  );
}
