import 'dart:math';

import 'package:abyss/domain/action/attack_transition_base_action.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attack_transition_base_helper.dart';

/// The history entry of an assault of [army] on the Faille of
/// [createAttackScenario], fought with the dice of [seed].
HistoryEntry? _entryOf(Map<UnitType, int> army, int seed) {
  final scenario = createAttackScenario(stock: army);
  final action = AttackTransitionBaseAction(
    targetX: 1,
    targetY: 1,
    level: 1,
    selectedUnits: army,
    random: Random(seed),
  );
  final result = action.execute(scenario.game, scenario.player);
  return action.makeHistoryEntry(scenario.game, scenario.player, result, 7);
}

void main() {
  group('AttackTransitionBaseAction makeHistoryEntry', () {
    test('records a capture', () {
      final entry = _entryOf(
        {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 30},
        42,
      )! as CaptureEntry;
      expect(entry.captured, isTrue);
      expect(entry.transitionBaseName, 'Faille');
      expect(entry.turn, 7);
    });

    test('records a victory where the admiral fell, not captured', () {
      // 12 harpoonists + seed 94: the player wins but the admiral dies.
      final entry = _entryOf(
        {UnitType.abyssAdmiral: 1, UnitType.harpoonist: 12},
        94,
      )! as CaptureEntry;
      expect(entry.captured, isFalse);
      expect(entry.transitionBaseName, 'Faille');
    });

    test('records nothing after a defeat', () {
      expect(
        _entryOf({UnitType.abyssAdmiral: 1, UnitType.scout: 1}, 42),
        isNull,
      );
    });
  });
}
