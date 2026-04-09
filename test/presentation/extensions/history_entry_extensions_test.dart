import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/extensions/history_entry_category_extensions.dart';
import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';

FightResult _fakeFightResult({required bool victory}) {
  final combatant = Combatant(
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
    initialPlayerCombatants: [combatant],
    finalPlayerCombatants: [combatant],
    initialMonsterCount: 1,
    finalMonsterCount: 0,
  );
}

CombatEntry _combatEntry({required bool victory}) => CombatEntry(
  turn: 1,
  victory: victory,
  targetX: 0,
  targetY: 0,
  lair: const MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 1,
  ),
  fightResult: _fakeFightResult(victory: victory),
  loot: const {},
  sent: const {},
  survivorsIntact: const {},
  wounded: const {},
  dead: const {},
);

void main() {
  final theme = AbyssTheme.create();

  group('HistoryEntryDisplay.isTappable', () {
    test('combat victory is tappable', () {
      expect(_combatEntry(victory: true).isTappable, isTrue);
    });

    test('combat defeat is tappable', () {
      expect(_combatEntry(victory: false).isTappable, isTrue);
    });

    test('building entry is not tappable', () {
      final entry = BuildingEntry(
        turn: 2,
        buildingType: BuildingType.algaeFarm,
        newLevel: 3,
      );
      expect(entry.isTappable, isFalse);
    });
  });

  group('HistoryEntryDisplay.accentColor', () {
    test('combat victory glows with success color', () {
      expect(
        _combatEntry(victory: true).accentColor(theme),
        AbyssColors.success,
      );
    });

    test('combat defeat glows with theme error color', () {
      expect(
        _combatEntry(victory: false).accentColor(theme),
        theme.colorScheme.error,
      );
    });

    test('building entry delegates to category background color', () {
      final entry = BuildingEntry(
        turn: 1,
        buildingType: BuildingType.laboratory,
        newLevel: 2,
      );
      expect(
        entry.accentColor(theme),
        entry.category.backgroundColor(theme),
      );
    });
  });
}
