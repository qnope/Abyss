import '../../../event/event_state.dart';
import '../../../event/event_turn_outcome.dart';
import '../temporary_objective.dart';
import '../temporary_objective_end.dart';
import '../temporary_objective_kind.dart';
import '../temporary_objective_source.dart';

/// « Repousse le banc de prédateurs » once the player chose to face them,
/// through the turn at whose end they strike: done if the fight is won,
/// failed if lost. Baited predators set no objective.
class PredatorsObjectiveSource extends TemporaryObjectiveSource {
  const PredatorsObjectiveSource();

  @override
  TemporaryObjective? activeIn(EventState state, int turn) {
    final int? due = state.predatorsTurn;
    if (state.predatorWave == null || due == null || turn > due) return null;
    return _objective(due);
  }

  @override
  TemporaryObjectiveEnd? endedBy(EventTurnOutcome outcome) {
    final fight = outcome.predators;
    if (fight == null) return null;
    return TemporaryObjectiveEnd(
      objective: _objective(fight.turn),
      outcome:
          fight.victory
              ? TemporaryObjectiveOutcome.done
              : TemporaryObjectiveOutcome.failed,
    );
  }

  static TemporaryObjective _objective(int due) => TemporaryObjective(
    kind: TemporaryObjectiveKind.predators,
    title: 'Repousse le banc de prédateurs',
    lastTurn: due,
  );
}
