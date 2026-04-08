import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

void main() {
  group('FightMonsterAction casualty accounting', () {
    test('wounded units are restored to player stock', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.medium,
        unitCount: 4,
        stock: {UnitType.harpoonist: 6},
      );

      final int initialStock =
          scenario.player.units[UnitType.harpoonist]!.count;

      final action = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 6},
        random: Random(3),
      );

      final result = action.execute(scenario.game, scenario.player)
          as FightMonsterResult;

      // Sent everything.
      expect(result.sent, {UnitType.harpoonist: 6});

      final int sent = result.sent[UnitType.harpoonist] ?? 0;
      final int survivors = result.survivorsIntact[UnitType.harpoonist] ?? 0;
      final int wounded = result.wounded[UnitType.harpoonist] ?? 0;
      final int dead = result.dead[UnitType.harpoonist] ?? 0;

      // All sent units must be accounted for.
      expect(survivors + wounded + dead, sent);

      // Final stock == initial - sent + wounded (only wounded are restored
      // per the action spec).
      final int finalStock =
          scenario.player.units[UnitType.harpoonist]!.count;
      expect(finalStock, initialStock - sent + wounded);
    });

    test('seeded run is reproducible', () {
      // Two independent scenarios with the same seed should produce the
      // same casualty split.
      final s1 = createFightScenario(
        difficulty: MonsterDifficulty.medium,
        unitCount: 4,
        stock: {UnitType.harpoonist: 6},
      );
      final s2 = createFightScenario(
        difficulty: MonsterDifficulty.medium,
        unitCount: 4,
        stock: {UnitType.harpoonist: 6},
      );

      final r1 = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 6},
        random: Random(42),
      ).execute(s1.game, s1.player) as FightMonsterResult;

      final r2 = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        selectedUnits: {UnitType.harpoonist: 6},
        random: Random(42),
      ).execute(s2.game, s2.player) as FightMonsterResult;

      expect(r1.victory, r2.victory);
      expect(r1.wounded, r2.wounded);
      expect(r1.dead, r2.dead);
      expect(r1.survivorsIntact, r2.survivorsIntact);
      expect(r1.loot, r2.loot);
    });
  });
}
