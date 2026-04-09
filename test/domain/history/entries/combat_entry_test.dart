import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

FightResult _fakeFightResult({required bool victory}) {
  final playerCombatant = Combatant(
    side: CombatSide.player,
    typeKey: 'scout',
    maxHp: 10,
    atk: 3,
    def: 1,
  );
  return FightResult(
    winner: victory ? CombatSide.player : CombatSide.monster,
    turnCount: 1,
    turnSummaries: const [
      FightTurnSummary(
        turnNumber: 1,
        attacksPlayed: 2,
        critCount: 0,
        damageDealtByPlayer: 5,
        damageDealtByMonster: 3,
        playerAliveAtEnd: 1,
        monsterAliveAtEnd: 0,
        playerHpAtEnd: 7,
        monsterHpAtEnd: 0,
      ),
    ],
    initialPlayerCombatants: [playerCombatant],
    finalPlayerCombatants: [playerCombatant],
    initialMonsterCount: 1,
    finalMonsterCount: 0,
  );
}

void main() {
  group('CombatEntry', () {
    final lair = const MonsterLair(
      difficulty: MonsterDifficulty.medium,
      unitCount: 3,
    );

    test('victory builds French title with lair level', () {
      final entry = CombatEntry(
        turn: 5,
        victory: true,
        targetX: 3,
        targetY: 4,
        lair: lair,
        fightResult: _fakeFightResult(victory: true),
        loot: {ResourceType.algae: 12, ResourceType.coral: 8},
        sent: {UnitType.scout: 2, UnitType.harpoonist: 1},
        survivorsIntact: {UnitType.scout: 2},
        wounded: {UnitType.harpoonist: 1},
        dead: const {},
      );

      expect(entry.turn, 5);
      expect(entry.category, HistoryEntryCategory.combat);
      expect(entry.title, 'Victoire vs Tanière niv 2');
      expect(entry.victory, isTrue);
      expect(entry.targetX, 3);
      expect(entry.targetY, 4);
      expect(entry.lair, same(lair));
      expect(entry.fightResult.turnCount, 1);
      expect(entry.fightResult.turnSummaries, hasLength(1));
      expect(entry.loot[ResourceType.algae], 12);
      expect(entry.sent[UnitType.scout], 2);
      expect(entry.survivorsIntact[UnitType.scout], 2);
      expect(entry.wounded[UnitType.harpoonist], 1);
      expect(entry.dead, isEmpty);
      expect(entry.subtitle, isNull);
    });

    test('defeat switches title to Défaite', () {
      final entry = CombatEntry(
        turn: 7,
        victory: false,
        targetX: 1,
        targetY: 2,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.hard,
          unitCount: 5,
        ),
        fightResult: _fakeFightResult(victory: false),
        loot: const {},
        sent: {UnitType.guardian: 3},
        survivorsIntact: const {},
        wounded: const {},
        dead: {UnitType.guardian: 3},
      );

      expect(entry.title, 'Défaite vs Tanière niv 3');
      expect(entry.victory, isFalse);
      expect(entry.dead[UnitType.guardian], 3);
    });
  });
}
