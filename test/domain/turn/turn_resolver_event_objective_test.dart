import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_end.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event/effects/predators_test_helper.dart';
import '../event/effects/wreck_test_helper.dart';

/// Game of turn [turn] with a wreck sunk at the end of turn 12, to be
/// searched through turn 17, already in sight.
Game _wreckGame({int turn = 13}) {
  final player = wreckPlayer();
  final game = wreckGame(player, turn: turn);
  const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));
  player.addRevealedCell(1, player.eventState.wreckPosition!);
  return game;
}

/// Game of turn 12 whose predators are faced ([accept]) or baited, by a
/// base holding [harpoonists].
Game _predatorsGame({required bool accept, int harpoonists = 0}) {
  final player = threatenedPlayer(units: {UnitType.harpoonist: harpoonists});
  final game = Game.singlePlayer(player)..turn = 12;
  ChooseEventAction(accept: accept).execute(game, player);
  return game;
}

/// The single objective of an event that ended with the turn of [game].
TemporaryObjectiveEnd _endOf(Game game) =>
    TurnResolver().resolve(game, random: Random(4)).temporaryObjectives.single;

void main() {
  group('TurnResolver event objectives', () {
    test('a wreck searched during the turn is reported done, once', () {
      final game = _wreckGame(turn: 14);
      final at = game.humanPlayer.eventState.wreckPosition!;
      final search = CollectTreasureAction(targetX: at.x, targetY: at.y);
      expect(
        ActionExecutor().execute(search, game, game.humanPlayer).isSuccess,
        isTrue,
      );

      final end = _endOf(game);

      expect(end.objective.kind, TemporaryObjectiveKind.wreck);
      expect(end.objective.lastTurn, 17);
      expect(end.outcome, TemporaryObjectiveOutcome.done);
      expect(TurnResolver().resolve(game).temporaryObjectives, isEmpty);
    });

    test('a wreck left to sink is reported expired after its last turn', () {
      final game = _wreckGame();
      for (var turn = 13; turn <= 16; turn++) {
        final result = TurnResolver().resolve(game);
        expect(result.temporaryObjectives, isEmpty, reason: 'turn $turn');
      }

      final end = _endOf(game);

      expect(end.objective.kind, TemporaryObjectiveKind.wreck);
      expect(end.objective.lastTurn, 17);
      expect(end.outcome, TemporaryObjectiveOutcome.expired);
      expect(TurnResolver().resolve(game).temporaryObjectives, isEmpty);
    });

    test('predators repelled are reported done', () {
      final game = _predatorsGame(accept: true, harpoonists: 30);

      final end = _endOf(game);

      expect(end.objective.kind, TemporaryObjectiveKind.predators);
      expect(end.objective.lastTurn, 12);
      expect(end.outcome, TemporaryObjectiveOutcome.done);
      expect(TurnResolver().resolve(game).temporaryObjectives, isEmpty);
    });

    test('predators that win the fight are reported failed', () {
      final game = _predatorsGame(accept: true);

      final end = _endOf(game);

      expect(end.objective.kind, TemporaryObjectiveKind.predators);
      expect(end.outcome, TemporaryObjectiveOutcome.failed);
    });

    test('baited predators report nothing', () {
      final game = _predatorsGame(accept: false);
      expect(TurnResolver().resolve(game).temporaryObjectives, isEmpty);
    });
  });
}
