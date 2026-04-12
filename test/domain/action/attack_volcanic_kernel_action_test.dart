import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_volcanic_kernel_helper.dart';

void main() {
  group('AttackVolcanicKernelAction validate', () {
    test('fails when map is null', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 10},
      );
      scenario.game.levels.clear();
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });

    test('fails when cell is not volcanic kernel', () {
      final scenario = createKernelScenario(
        content: CellContentType.empty,
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 10},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Pas de noyau volcanique ici');
    });

    test('fails when kernel already captured', () {
      final scenario = createKernelScenario(
        collectedBy: 'someone',
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 10},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Noyau déjà capturé');
    });

    test('fails without abyss admiral', () {
      final scenario = createKernelScenario(
        stock: {UnitType.domeBreaker: 10},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.domeBreaker: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Un Amiral des Abysses est requis');
    });

    test('fails when units exceed stock', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 2},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 10},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unités insuffisantes');
    });

    test('succeeds on valid scenario', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 50},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 50},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isTrue);
    });
  });
}
