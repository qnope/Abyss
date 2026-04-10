import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transition_test_helper.dart';

void main() {
  final executor = ActionExecutor();

  /// Captures the faille and descends scouts to Level 2.
  void captureAndDescend(
    dynamic game,
    dynamic player, {
    int scoutsToDescend = 3,
  }) {
    executor.execute(
      AttackTransitionBaseAction(
        targetX: kFailleX,
        targetY: kFailleY,
        level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 30,
        },
        random: Random(42),
      ),
      game,
      player,
    );
    executor.execute(
      DescendAction(
        transitionX: kFailleX,
        transitionY: kFailleY,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: scoutsToDescend},
      ),
      game,
      player,
    );
  }

  group('Multi-level resource sharing', () {
    test('production applies to global pool after descent', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;
      captureAndDescend(game, player);

      // Record resources before turn
      final algaeBefore =
          player.resources[ResourceType.algae]!.amount;
      final coralBefore =
          player.resources[ResourceType.coral]!.amount;

      // End turn applies production from buildings
      executor.execute(EndTurnAction(), game, player);

      // Production from algaeFarm level 3 and solarPanel level 3
      // should have changed the global resource pool
      final algaeAfter =
          player.resources[ResourceType.algae]!.amount;
      final coralAfter =
          player.resources[ResourceType.coral]!.amount;

      // Algae changes due to production minus unit consumption
      expect(algaeAfter, isNot(equals(algaeBefore)));
      // Coral stays same (no coral mine active)
      expect(coralAfter, equals(coralBefore));
    });

    test('units on level 2 exist after end turn', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;
      captureAndDescend(game, player, scoutsToDescend: 5);

      expect(player.unitsOnLevel(2)[UnitType.scout]!.count, 5);

      // End turn should not remove level 2 units
      executor.execute(EndTurnAction(), game, player);

      expect(player.unitsOnLevel(2)[UnitType.scout]!.count, 5);
    });

    test('game turn advances correctly across levels', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;
      captureAndDescend(game, player);

      expect(game.turn, 1);

      executor.execute(EndTurnAction(), game, player);
      expect(game.turn, 2);

      executor.execute(EndTurnAction(), game, player);
      expect(game.turn, 3);

      // Both levels still accessible
      expect(game.levels[1], isNotNull);
      expect(game.levels[2], isNotNull);
    });

    test('level 1 unit consumption uses only level 1 units', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;
      captureAndDescend(game, player, scoutsToDescend: 5);

      final scoutsL1 =
          player.unitsOnLevel(1)[UnitType.scout]!.count;
      final scoutsL2 =
          player.unitsOnLevel(2)[UnitType.scout]!.count;

      // With algaeFarm level 3 + solarPanel level 3 and ample
      // resources, no units should starve
      executor.execute(EndTurnAction(), game, player);

      // Level 2 scouts unchanged (not consumed by turn resolver)
      expect(
        player.unitsOnLevel(2)[UnitType.scout]!.count,
        scoutsL2,
      );
      // Level 1 scouts unchanged (enough algae production)
      expect(
        player.unitsOnLevel(1)[UnitType.scout]!.count,
        scoutsL1,
      );
    });
  });
}
