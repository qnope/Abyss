import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fight_monster_action_helper.dart';

void main() {
  group('FightMonsterAction military bonus', () {
    test('combatant atk reflects player military level', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 1},
        militaryResearchLevel: 3,
      );

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 1},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      final int baseAtk = UnitStats.forType(UnitType.harpoonist).atk;
      final int expectedAtk = (baseAtk * 1.6).round();
      expect(
        result.fight!.initialPlayerCombatants.first.atk,
        expectedAtk,
      );
    });

    test('level 0 leaves atk unchanged', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 1},
        militaryResearchLevel: 0,
      );

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 1},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      expect(
        result.fight!.initialPlayerCombatants.first.atk,
        UnitStats.forType(UnitType.harpoonist).atk,
      );
    });

    test('unlocked == false yields no bonus', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 1},
      );
      // Force a researched-but-locked branch state. The action should still
      // treat it as level 0 because `unlocked` is false.
      final TechBranchState mil =
          scenario.player.techBranches[TechBranch.military]!;
      mil.unlocked = false;
      mil.researchLevel = 5;

      final result = FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 1},
        random: Random(0),
      ).execute(scenario.game, scenario.player) as FightMonsterResult;

      expect(
        result.fight!.initialPlayerCombatants.first.atk,
        UnitStats.forType(UnitType.harpoonist).atk,
      );
    });

    test('monster combatants are unaffected', () {
      final scenario = createFightScenario(
        difficulty: MonsterDifficulty.easy,
        unitCount: 1,
        stock: {UnitType.harpoonist: 1},
        militaryResearchLevel: 3,
      );

      // Execute the action so the military level has a chance to propagate.
      FightMonsterAction(
        targetX: 1,
        targetY: 1,
        level: 1,
        selectedUnits: {UnitType.harpoonist: 1},
        random: Random(0),
      ).execute(scenario.game, scenario.player);

      // The monster side uses `CombatantBuilder.monsterCombatantsFrom`, which
      // does not receive the military research level. Rebuilding the list
      // from the same lair must yield monsters with raw stats.
      final MonsterLair lair =
          scenario.game.levels[1]!.cellAt(1, 1).lair!;
      final List<Combatant> monsterCombatants =
          CombatantBuilder.monsterCombatantsFrom(lair);
      final int monsterBaseAtk = MonsterUnitStats.forLevel(1).atk;
      expect(monsterCombatants, isNotEmpty);
      for (final Combatant c in monsterCombatants) {
        expect(c.atk, monsterBaseAtk);
      }
    });
  });
}
