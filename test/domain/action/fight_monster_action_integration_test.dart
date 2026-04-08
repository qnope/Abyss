import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

void main() {
  group('FightMonsterAction integration', () {
    test('victory full flow: cell collected, loot applied, stock preserved',
        () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 4,
        stock: {UnitType.harpoonist: 20},
      );
      scenario.player.addRevealedCell(GridPosition(x: 1, y: 1));

      final Map<ResourceType, int> before = <ResourceType, int>{
        for (final entry in scenario.player.resources.entries)
          entry.key: entry.value.amount,
      };
      final int initialHarpoonists =
          scenario.player.units[UnitType.harpoonist]!.count;

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 5},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      expect(result.victory, isTrue);

      final cell = scenario.game.gameMap!.cellAt(1, 1);
      expect(cell.isCollected, isTrue);
      expect(cell.collectedBy, scenario.player.id);
      expect(cell.lair, isNotNull,
          reason: 'Collected lair should keep its composition');

      for (final entry in result.loot.entries) {
        final int after = scenario.player.resources[entry.key]!.amount;
        expect(after - before[entry.key]!, entry.value,
            reason: 'Resource ${entry.key} delta should match loot');
      }

      final int sent = result.sent[UnitType.harpoonist] ?? 0;
      final int wounded = result.wounded[UnitType.harpoonist] ?? 0;
      final int finalStock =
          scenario.player.units[UnitType.harpoonist]!.count;
      expect(finalStock, initialHarpoonists - sent + wounded);
    });

    test('defeat full flow: cell untouched, resources intact, unit consumed',
        () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.hard,
        unitCount: 150,
        stock: {UnitType.saboteur: 1},
      );
      scenario.player.addRevealedCell(GridPosition(x: 1, y: 1));

      final Map<ResourceType, int> before = <ResourceType, int>{
        for (final entry in scenario.player.resources.entries)
          entry.key: entry.value.amount,
      };

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.saboteur: 1},
        random: Random(1),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      expect(result.victory, isFalse);

      final cell = scenario.game.gameMap!.cellAt(1, 1);
      expect(cell.isCollected, isFalse);
      expect(cell.collectedBy, isNull);

      for (final entry in before.entries) {
        expect(
          scenario.player.resources[entry.key]!.amount,
          entry.value,
          reason: 'Resource ${entry.key} must be unchanged on defeat',
        );
      }

      // Sent saboteur not in stock anymore (neither survived nor wounded).
      final int finalStock =
          scenario.player.units[UnitType.saboteur]!.count;
      final int wounded = result.wounded[UnitType.saboteur] ?? 0;
      expect(finalStock, wounded,
          reason: 'Only wounded saboteurs should remain in stock');
      expect(result.sent[UnitType.saboteur], 1);
    });

    test('casualty restoration: wounded units are returned to stock', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.medium,
        unitCount: 6,
        stock: {UnitType.harpoonist: 8},
      );
      scenario.player.addRevealedCell(GridPosition(x: 1, y: 1));

      final int initialStock =
          scenario.player.units[UnitType.harpoonist]!.count;

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 8},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      final int sent = result.sent[UnitType.harpoonist] ?? 0;
      final int survivors = result.survivorsIntact[UnitType.harpoonist] ?? 0;
      final int wounded = result.wounded[UnitType.harpoonist] ?? 0;
      final int dead = result.dead[UnitType.harpoonist] ?? 0;

      expect(result.victory, isTrue);
      expect(sent, 8);
      expect(survivors + wounded + dead, sent);
      final int totalWounded =
          result.wounded.values.fold<int>(0, (a, b) => a + b);
      expect(totalWounded, greaterThan(0),
          reason: 'Balanced fight should produce at least one wounded unit');

      final int finalStock =
          scenario.player.units[UnitType.harpoonist]!.count;
      expect(finalStock, initialStock - sent + wounded);
    });
  });
}
