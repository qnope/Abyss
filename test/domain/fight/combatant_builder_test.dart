import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/combatant_builder.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/unit/unit_stats.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('CombatantBuilder.playerCombatantsFrom', () {
    test('expands selected units into per-unit combatants in order', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{
          UnitType.scout: 3,
          UnitType.harpoonist: 2,
        },
      );

      expect(combatants.length, 5);

      final UnitStats scoutStats = UnitStats.forType(UnitType.scout);
      final UnitStats harpoonStats = UnitStats.forType(UnitType.harpoonist);

      for (int i = 0; i < 3; i++) {
        expect(combatants[i].side, CombatSide.player);
        expect(combatants[i].typeKey, 'scout');
        expect(combatants[i].maxHp, scoutStats.hp);
        expect(combatants[i].atk, scoutStats.atk);
        expect(combatants[i].def, scoutStats.def);
        expect(combatants[i].currentHp, scoutStats.hp);
      }
      for (int i = 3; i < 5; i++) {
        expect(combatants[i].side, CombatSide.player);
        expect(combatants[i].typeKey, 'harpoonist');
        expect(combatants[i].maxHp, harpoonStats.hp);
        expect(combatants[i].atk, harpoonStats.atk);
        expect(combatants[i].def, harpoonStats.def);
      }
    });

    test('entries with count == 0 are skipped', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{
          UnitType.scout: 0,
          UnitType.guardian: 2,
          UnitType.saboteur: 0,
        },
      );

      expect(combatants.length, 2);
      expect(combatants.every((Combatant c) => c.typeKey == 'guardian'), true);
    });

    test('empty map returns empty list', () {
      expect(
        CombatantBuilder.playerCombatantsFrom(const <UnitType, int>{}),
        isEmpty,
      );
    });
  });

  group('CombatantBuilder.monsterCombatantsFrom', () {
    test('expands easy lair into level-1 combatants', () {
      final MonsterLair lair = const MonsterLair(
        difficulty: MonsterDifficulty.easy,
        unitCount: 4,
      );

      final List<Combatant> combatants =
          CombatantBuilder.monsterCombatantsFrom(lair);

      final MonsterUnitStats level1 = MonsterUnitStats.forLevel(1);
      expect(combatants.length, 4);
      for (final Combatant c in combatants) {
        expect(c.side, CombatSide.monster);
        expect(c.typeKey, 'monsterL1');
        expect(c.maxHp, level1.hp);
        expect(c.atk, level1.atk);
        expect(c.def, level1.def);
        expect(c.currentHp, level1.hp);
      }
    });

    test('hard lair uses monsterL3 key and level-3 stats', () {
      final MonsterLair lair = const MonsterLair(
        difficulty: MonsterDifficulty.hard,
        unitCount: 2,
      );

      final List<Combatant> combatants =
          CombatantBuilder.monsterCombatantsFrom(lair);

      final MonsterUnitStats level3 = MonsterUnitStats.forLevel(3);
      expect(combatants.length, 2);
      expect(combatants.first.typeKey, 'monsterL3');
      expect(combatants.first.maxHp, level3.hp);
      expect(combatants.first.atk, level3.atk);
      expect(combatants.first.def, level3.def);
    });
  });

  group('military bonus', () {
    test('level 0 keeps base atk', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{UnitType.harpoonist: 1},
      );
      expect(
        combatants.first.atk,
        UnitStats.forType(UnitType.harpoonist).atk,
      );
    });

    test('level 3 multiplies by 1.6', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{UnitType.harpoonist: 1},
        militaryResearchLevel: 3,
      );
      expect(
        combatants.first.atk,
        (UnitStats.forType(UnitType.harpoonist).atk * 1.6).round(),
      );
    });

    test('level 5 multiplies by 2.0', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{UnitType.harpoonist: 1},
        militaryResearchLevel: 5,
      );
      expect(
        combatants.first.atk,
        UnitStats.forType(UnitType.harpoonist).atk * 2,
      );
    });

    test('bonus does not affect hp or def', () {
      final List<Combatant> combatants = CombatantBuilder.playerCombatantsFrom(
        <UnitType, int>{UnitType.guardian: 1},
        militaryResearchLevel: 3,
      );
      expect(combatants.first.def, 6);
      expect(combatants.first.maxHp, 25);
    });

    test('bonus does not affect monster combatants', () {
      final MonsterLair lair = const MonsterLair(
        difficulty: MonsterDifficulty.easy,
        unitCount: 2,
      );
      final List<Combatant> combatants =
          CombatantBuilder.monsterCombatantsFrom(lair);
      final MonsterUnitStats level1 = MonsterUnitStats.forLevel(1);
      for (final Combatant c in combatants) {
        expect(c.atk, level1.atk);
      }
    });
  });

  group('CombatantBuilder.unitTypeFromKey', () {
    test('returns matching UnitType for known key', () {
      expect(CombatantBuilder.unitTypeFromKey('scout'), UnitType.scout);
      expect(
        CombatantBuilder.unitTypeFromKey('harpoonist'),
        UnitType.harpoonist,
      );
    });

    test('returns null for monster key', () {
      expect(CombatantBuilder.unitTypeFromKey('monsterL1'), isNull);
    });

    test('returns null for unknown key', () {
      expect(CombatantBuilder.unitTypeFromKey('unknown'), isNull);
    });
  });
}
