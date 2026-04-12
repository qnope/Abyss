import 'dart:math';

import 'package:abyss/domain/action/attack_volcanic_kernel_action.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_volcanic_kernel_helper.dart';

void main() {
  group('AttackVolcanicKernelAction makeHistoryEntry', () {
    test('returns CaptureEntry when captured', () {
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
      expect(r.captured, isTrue);

      final entry = action.makeHistoryEntry(
        scenario.game, scenario.player, result, 5,
      );
      expect(entry, isA<CaptureEntry>());
      final capture = entry! as CaptureEntry;
      expect(capture.turn, 5);
      expect(capture.transitionBaseName, 'Noyau Volcanique');
    });

    test('returns null when not captured', () {
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
      expect(r.captured, isFalse);

      final entry = action.makeHistoryEntry(
        scenario.game, scenario.player, result, 5,
      );
      expect(entry, isNull);
    });
  });
}
