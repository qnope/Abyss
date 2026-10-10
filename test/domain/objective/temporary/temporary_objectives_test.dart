import 'dart:math';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/temporary/temporary_objective_kind.dart';
import 'package:abyss/domain/objective/temporary/temporary_objectives.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../event/effects/predators_test_helper.dart';
import '../../event/effects/wreck_test_helper.dart';

/// Game of turn 12 whose predators are faced when [accept] is `true`,
/// baited when `false`, still waiting for a choice when `null`.
Game _predatorsGame({bool? accept}) {
  final player = threatenedPlayer();
  final game = Game.singlePlayer(player)..turn = 12;
  if (accept != null) ChooseEventAction(accept: accept).execute(game, player);
  return game;
}

void main() {
  group('TemporaryObjectives.activeOf', () {
    test('none without a wreck on the map nor predators faced', () {
      final player = wreckPlayer();
      expect(TemporaryObjectives.activeOf(wreckGame(player), player), isEmpty);
    });

    test('a wreck on the map asks to search it before its last turn', () {
      final player = wreckPlayer();
      final game = wreckGame(player, turn: 13);
      const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));

      final objective = TemporaryObjectives.activeOf(game, player).single;

      expect(objective.kind, TemporaryObjectiveKind.wreck);
      expect(objective.title, "Fouille l'épave d'ici la fin du tour 17");
      expect(objective.lastTurn, 17);
    });

    test('a searched wreck is no longer to search', () {
      final player = wreckPlayer();
      final game = wreckGame(player, turn: 13);
      const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));
      WreckEffect.searched(player, player.eventState.wreckPosition!);

      expect(TemporaryObjectives.activeOf(game, player), isEmpty);
    });

    test('predators faced are to repel by the end of the turn', () {
      final game = _predatorsGame(accept: true);

      final objective =
          TemporaryObjectives.activeOf(game, game.humanPlayer).single;

      expect(objective.kind, TemporaryObjectiveKind.predators);
      expect(objective.title, 'Repousse le banc de prédateurs');
      expect(objective.lastTurn, 12);
    });

    test('predators baited or not chosen yet bring no objective', () {
      for (final accept in [false, null]) {
        final game = _predatorsGame(accept: accept);
        expect(
          TemporaryObjectives.activeOf(game, game.humanPlayer),
          isEmpty,
          reason: '$accept',
        );
      }
    });
  });
}
