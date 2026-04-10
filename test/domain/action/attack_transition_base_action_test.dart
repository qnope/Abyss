import 'dart:math';

import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_transition_base_helper.dart';

void main() {
  group('AttackTransitionBaseAction validate', () {
    test('fails when map is null', () {
      final scenario = createAttackScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      scenario.game.levels.clear();
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });

    test('fails when cell is not a transition base', () {
      final scenario = createAttackScenario(
        content: CellContentType.empty,
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Pas de base de transition ici');
    });

    test('fails when base is already captured', () {
      final scenario = createAttackScenario(
        capturedBy: 'someone',
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Base déjà capturée');
    });

    test('fails without required building for faille', () {
      final scenario = createAttackScenario(
        descentModuleLevel: 0,
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Bâtiment requis manquant');
    });

    test('fails without required building for cheminee', () {
      final scenario = createAttackScenario(
        baseType: TransitionBaseType.cheminee,
        pressureCapsuleLevel: 0,
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Bâtiment requis manquant');
    });

    test('fails without abyss admiral', () {
      final scenario = createAttackScenario(
        stock: {UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Un Amiral des Abysses est requis');
    });

    test('fails when units exceed stock', () {
      final scenario = createAttackScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 2},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unités insuffisantes');
    });

    test('succeeds on valid scenario', () {
      final scenario = createAttackScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
    });
  });

  group('AttackTransitionBaseAction execute', () {
    test('victory with admiral alive captures the base', () {
      // Overwhelm faille guardians: 1 boss (100hp/15atk/10def) + 5 sentinels
      // Send 1 admiral + many strong units to guarantee victory+admiral alive
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
      expect(result, isA<AttackTransitionBaseResult>());
      final r = result as AttackTransitionBaseResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isTrue);
      expect(r.captured, isTrue);

      final base = scenario.game.levels[1]!
          .cellAt(1, 1).transitionBase!;
      expect(base.isCaptured, isTrue);
      expect(base.capturedBy, 'test-uuid');
    });

    test('defeat loses all sent units', () {
      // Send minimal force against faille guardians to guarantee defeat
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
      expect(result, isA<AttackTransitionBaseResult>());
      final r = result as AttackTransitionBaseResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isFalse);
      expect(r.captured, isFalse);

      // Base remains neutral
      final base = scenario.game.levels[1]!
          .cellAt(1, 1).transitionBase!;
      expect(base.isCaptured, isFalse);
    });
  });
}
