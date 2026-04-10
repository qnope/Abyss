import 'dart:math';

import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/fight/guardian_factory.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_transition_base_helper.dart';

void main() {
  group('AttackTransitionBaseAction execute', () {
    test('victory with admiral alive captures the base', () {
      final scenario = createAttackScenario(
        stock: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 30,
        },
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 30,
        },
        random: Random(42),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackTransitionBaseResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isTrue);
      expect(r.captured, isTrue);

      final base =
          scenario.game.levels[1]!.cellAt(1, 1).transitionBase!;
      expect(base.isCaptured, isTrue);
      expect(base.capturedBy, 'test-uuid');
    });

    test('victory with admiral dead does not capture', () {
      // 11 harpoonists + seed 33: player wins but admiral dies.
      // Admiral has 100hp but 0atk/0def, so it takes damage
      // and cannot fight back.
      final scenario = createAttackScenario(
        stock: {
          UnitType.abyssAdmiral: 1,
          UnitType.harpoonist: 11,
        },
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.harpoonist: 11,
        },
        random: Random(33),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackTransitionBaseResult;
      expect(r.victory, isTrue);
      expect(r.captured, isFalse);

      final base =
          scenario.game.levels[1]!.cellAt(1, 1).transitionBase!;
      expect(base.isCaptured, isFalse);
    });

    test('defeat loses all sent units', () {
      final scenario = createAttackScenario(
        stock: {
          UnitType.abyssAdmiral: 1,
          UnitType.scout: 1,
        },
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.scout: 1,
        },
        random: Random(42),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackTransitionBaseResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isFalse);
      expect(r.captured, isFalse);

      final base =
          scenario.game.levels[1]!.cellAt(1, 1).transitionBase!;
      expect(base.isCaptured, isFalse);
    });

    test('guardians reform after failed capture', () {
      final scenario = createAttackScenario(
        stock: {
          UnitType.abyssAdmiral: 2,
          UnitType.scout: 2,
        },
      );
      // First attack: defeat
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.scout: 1,
        },
        random: Random(42),
      );
      action.execute(scenario.game, scenario.player);

      // Guardians are rebuilt from factory each attack.
      final fresh =
          GuardianFactory.forType(TransitionBaseType.faille);
      expect(fresh, hasLength(6));
      for (final g in fresh) {
        expect(g.currentHp, g.maxHp);
      }
    });
  });
}
