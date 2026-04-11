import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
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

    test('succeeds without descent module (not required for attack)', () {
      final scenario = createAttackScenario(
        descentModuleLevel: 0,
        stock: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 10},
      );
      final action = AttackTransitionBaseAction(
        targetX: 1, targetY: 1, level: 1,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
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
}
