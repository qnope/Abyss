import 'dart:math';

import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_volcanic_kernel_helper.dart';

void main() {
  group('AttackVolcanicKernelAction execute', () {
    test('victory with admiral alive captures the kernel', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 80},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 80,
        },
        random: Random(0),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackVolcanicKernelResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isTrue);
      expect(r.captured, isTrue);

      final cell = scenario.game.levels[3]!.cellAt(1, 1);
      expect(cell.isCollected, isTrue);
      expect(cell.collectedBy, 'test-uuid');
    });

    test('victory with admiral dead does not capture', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 30},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 30,
        },
        random: Random(1),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackVolcanicKernelResult;
      expect(r.victory, isTrue);
      expect(r.captured, isFalse);

      final cell = scenario.game.levels[3]!.cellAt(1, 1);
      expect(cell.isCollected, isFalse);
    });

    test('defeat loses units and does not capture', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.scout: 1},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.scout: 1,
        },
        random: Random(0),
      );
      final result = action.execute(scenario.game, scenario.player);
      final r = result as AttackVolcanicKernelResult;
      expect(r.isSuccess, isTrue);
      expect(r.victory, isFalse);
      expect(r.captured, isFalse);

      final cell = scenario.game.levels[3]!.cellAt(1, 1);
      expect(cell.isCollected, isFalse);
    });

    test('casualties are properly resolved', () {
      final scenario = createKernelScenario(
        stock: {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 80},
      );
      final action = AttackVolcanicKernelAction(
        targetX: 1, targetY: 1, level: 3,
        selectedUnits: {
          UnitType.abyssAdmiral: 1,
          UnitType.domeBreaker: 80,
        },
        random: Random(0),
      );
      final r = action.execute(scenario.game, scenario.player)
          as AttackVolcanicKernelResult;
      expect(r.sent, isNotEmpty);
      final totalOut = r.survivorsIntact.values.fold<int>(0, (a, b) => a + b)
          + r.wounded.values.fold<int>(0, (a, b) => a + b)
          + r.dead.values.fold<int>(0, (a, b) => a + b);
      final totalSent = r.sent.values.fold<int>(0, (a, b) => a + b);
      expect(totalOut, totalSent);
    });
  });
}
