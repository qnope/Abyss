import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

void main() {
  group('FightMonsterAction defeat', () {
    test('a single scout loses against a level-3 lair', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.hard,
        unitCount: 5,
        stock: {UnitType.scout: 1},
      );

      final Map<ResourceType, int> beforeAmounts = <ResourceType, int>{
        for (final entry in scenario.player.resources.entries)
          entry.key: entry.value.amount,
      };

      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.scout: 1},
        random: Random(1),
      );

      final result = action.execute(scenario.game, scenario.player)
          as FightMonsterResult;

      expect(result.victory, isFalse);

      final cell = scenario.game.levels[1]!.cellAt(1, 1);
      expect(cell.isCollected, isFalse);
      expect(cell.collectedBy, isNull);

      // Resources strictly unchanged.
      for (final entry in beforeAmounts.entries) {
        expect(
          scenario.player.resources[entry.key]!.amount,
          entry.value,
          reason: 'Resource ${entry.key} should be unchanged on defeat',
        );
      }

      // wounded + dead should sum to the sent units (per type).
      final int woundedScouts = result.wounded[UnitType.scout] ?? 0;
      final int deadScouts = result.dead[UnitType.scout] ?? 0;
      expect(woundedScouts + deadScouts, 1);
      expect(result.sent[UnitType.scout], 1);
      // survivorsIntact should be empty (we lost the fight with one unit).
      expect(result.survivorsIntact[UnitType.scout] ?? 0, 0);
    });
  });
}
