import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/send_reinforcements_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transition_test_helper.dart';

void main() {
  final executor = ActionExecutor();

  /// Captures the faille and descends scouts to Level 2.
  void captureAndDescend(
    dynamic game,
    dynamic player,
  ) {
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
        selectedUnits: {UnitType.scout: 3},
      ),
      game,
      player,
    );
  }

  group('Reinforcement pipeline', () {
    test('send reinforcements -> end turn -> units arrive', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;
      captureAndDescend(game, player);

      // Pre-conditions after descent
      final scoutsL1Before = player.unitsOnLevel(1)[UnitType.scout]!.count;
      final scoutsL2Before = player.unitsOnLevel(2)[UnitType.scout]!.count;
      expect(scoutsL2Before, 3);

      // Send 4 scouts as reinforcements
      final reinforce = SendReinforcementsAction(
        transitionX: kFailleX,
        transitionY: kFailleY,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 4},
      );
      final result = executor.execute(reinforce, game, player);
      expect(result.isSuccess, isTrue);

      // Scouts removed from Level 1
      expect(
        player.unitsOnLevel(1)[UnitType.scout]!.count,
        scoutsL1Before - 4,
      );

      // Pending reinforcement created
      expect(player.pendingReinforcements, hasLength(1));
      final order = player.pendingReinforcements.first;
      expect(order.toLevel, 2);
      expect(order.units[UnitType.scout], 4);

      // Turn 1 -> 2: reinforcements depart this turn
      executor.execute(EndTurnAction(), game, player);
      // isReadyToArrive checks currentTurn > departTurn.
      // Resolver runs before game.turn++, so on turn 1 departure
      // they arrive when resolver sees turn 2 (next end-turn).
      expect(player.pendingReinforcements, hasLength(1));

      // Turn 2 -> 3: reinforcements arrive
      executor.execute(EndTurnAction(), game, player);
      expect(
        player.unitsOnLevel(2)[UnitType.scout]!.count,
        scoutsL2Before + 4,
      );
      expect(player.pendingReinforcements, isEmpty);
    });

    test('reinforcements fail before descent', () {
      final s = buildTransitionScenario();
      // Capture but do not descend
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
        s.game,
        s.player,
      );

      // Level 2 map not generated yet -> reinforce should fail
      final reinforce = SendReinforcementsAction(
        transitionX: kFailleX,
        transitionY: kFailleY,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = executor.execute(reinforce, s.game, s.player);
      expect(result.isSuccess, isFalse);
    });
  });
}
