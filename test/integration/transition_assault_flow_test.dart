import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/descend_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'transition_test_helper.dart';

void main() {
  final executor = ActionExecutor();

  group('Full assault flow', () {
    test('attack -> capture -> descend -> level 2 generated', () {
      final s = buildTransitionScenario();
      final game = s.game;
      final player = s.player;

      // 1. Faille is present but not captured
      final faille = game.levels[1]!
          .cellAt(kFailleX, kFailleY)
          .transitionBase!;
      expect(faille.isCaptured, isFalse);

      // 2. Attack the transition base with admiral + combat units
      final attack = AttackTransitionBaseAction(
        targetX: kFailleX,
        targetY: kFailleY,
        level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 30,
        },
        random: Random(42),
      );
      final attackResult = executor.execute(attack, game, player);
      expect(attackResult.isSuccess, isTrue);

      // 3. Faille is now captured
      expect(faille.isCaptured, isTrue);
      expect(faille.capturedBy, player.id);

      // 4. Descend with scouts
      final descend = DescendAction(
        transitionX: kFailleX,
        transitionY: kFailleY,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 5},
      );
      final descendResult = executor.execute(descend, game, player);
      expect(descendResult.isSuccess, isTrue);

      // 5. Level 2 map is generated
      expect(game.levels[2], isNotNull);
      expect(game.levels[2]!.width, 20);

      // 6. Units transferred to Level 2
      expect(player.unitsOnLevel(2)[UnitType.scout]!.count, 5);
      expect(player.unitsOnLevel(1)[UnitType.scout]!.count, 5);

      // 7. Revealed cells exist on Level 2
      expect(player.revealedCellsPerLevel[2], isNotEmpty);

      // 8. End turn succeeds
      final endTurn = EndTurnAction();
      final turnResult = executor.execute(endTurn, game, player);
      expect(turnResult.isSuccess, isTrue);
      expect(game.turn, 2);
    });

    test('attack fails without admiral', () {
      final s = buildTransitionScenario();
      final attack = AttackTransitionBaseAction(
        targetX: kFailleX,
        targetY: kFailleY,
        level: 1,
        selectedUnits: {UnitType.domeBreaker: 10},
        random: Random(42),
      );
      final result = executor.execute(attack, s.game, s.player);
      expect(result.isSuccess, isFalse);
    });

    test('descend fails on uncaptured base', () {
      final s = buildTransitionScenario();
      final descend = DescendAction(
        transitionX: kFailleX,
        transitionY: kFailleY,
        fromLevel: 1,
        selectedUnits: {UnitType.scout: 1},
      );
      final result = executor.execute(descend, s.game, s.player);
      expect(result.isSuccess, isFalse);
    });
  });
}
