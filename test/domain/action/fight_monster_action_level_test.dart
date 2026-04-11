import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

Map<UnitType, Unit> _freshUnits({Map<UnitType, int>? counts}) {
  return {
    for (final t in UnitType.values)
      t: Unit(type: t, count: counts?[t] ?? 0),
  };
}

void main() {
  group('FightMonsterAction level support', () {
    test('validates against correct level map and units', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 5},
      );
      scenario.game.levels[2] = buildFightTestMap();
      scenario.player.unitsPerLevel[2] =
          _freshUnits(counts: {UnitType.harpoonist: 3});

      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 2,
        selectedUnits: {UnitType.harpoonist: 3},
      );
      expect(
        action.validate(scenario.game, scenario.player).isSuccess,
        isTrue,
      );
    });

    test('fails when units insufficient on target level', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 10},
      );
      scenario.game.levels[2] = buildFightTestMap();
      scenario.player.unitsPerLevel[2] =
          _freshUnits(counts: {UnitType.harpoonist: 1});

      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 2,
        selectedUnits: {UnitType.harpoonist: 5},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Unités insuffisantes');
    });

    test('deducts units from correct level on execute', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 10},
      );
      scenario.game.levels[2] = buildFightTestMap();
      scenario.player.unitsPerLevel[2] =
          _freshUnits(counts: {UnitType.harpoonist: 5});

      FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 2,
        selectedUnits: {UnitType.harpoonist: 3},
        random: Random(0),
      ).execute(scenario.game, scenario.player);

      // Level 1 untouched
      expect(
        scenario.player.unitsOnLevel(1)[UnitType.harpoonist]!.count,
        10,
      );
    });

    test('survivors restored to same level after fight', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 10},
      );
      scenario.game.levels[2] = buildFightTestMap(unitCount: 1);
      scenario.player.unitsPerLevel[2] =
          _freshUnits(counts: {UnitType.harpoonist: 8});

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 2,
        selectedUnits: {UnitType.harpoonist: 5},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      expect(result.isSuccess, isTrue);
      // Level 1 unchanged
      expect(
        scenario.player.unitsOnLevel(1)[UnitType.harpoonist]!.count,
        10,
      );
    });

    test('fails when level 2 map does not exist', () {
      final scenario = createFightScenario(
        stock: {UnitType.harpoonist: 5},
      );
      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 2,
        selectedUnits: {UnitType.harpoonist: 1},
      );
      final result = action.validate(scenario.game, scenario.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });
  });
}
