import '../../event/event_turn_outcome.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import 'sources/predators_objective_source.dart';
import 'sources/wreck_objective_source.dart';
import 'temporary_objective.dart';
import 'temporary_objective_end.dart';
import 'temporary_objective_source.dart';

/// The temporary objectives the events set, derived from the event state
/// of a player: nothing of theirs is saved.
abstract final class TemporaryObjectives {
  /// Every event able to set one, in display order; a new event adds its
  /// own [TemporaryObjectiveSource] here.
  static const List<TemporaryObjectiveSource> sources = [
    WreckObjectiveSource(),
    PredatorsObjectiveSource(),
  ];

  /// The objectives of [player] active during the current turn of [game].
  static List<TemporaryObjective> activeOf(Game game, Player player) => [
    for (final source in sources)
      if (source.activeIn(player.eventState, game.turn) case final active?)
        active,
  ];

  /// The objectives that ended while a turn ended, from what the events
  /// did then.
  static List<TemporaryObjectiveEnd> endedBy(EventTurnOutcome outcome) => [
    for (final source in sources)
      if (source.endedBy(outcome) case final ended?) ended,
  ];
}
