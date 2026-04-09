import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/history/history_filter.dart';

void main() {
  group('applyHistoryFilter', () {
    late List<HistoryEntry> entries;

    setUp(() {
      entries = <HistoryEntry>[
        BuildingEntry(
          turn: 1,
          buildingType: BuildingType.algaeFarm,
          newLevel: 1,
        ),
        ResearchEntry(turn: 1, branch: TechBranch.military, isUnlock: true),
        RecruitEntry(turn: 2, unitType: UnitType.scout, quantity: 3),
        ExploreEntry(turn: 2, targetX: 1, targetY: 2),
        CollectEntry(turn: 3, targetX: 4, targetY: 5, gains: const {}),
        CombatEntry(
          turn: 3,
          victory: true,
          targetX: 6,
          targetY: 7,
          lair: const MonsterLair(
            difficulty: MonsterDifficulty.easy,
            unitCount: 2,
          ),
          fightResult: const FightResult(
            winner: CombatSide.player,
            turnCount: 0,
            turnSummaries: [],
            initialPlayerCombatants: [],
            finalPlayerCombatants: [],
            initialMonsterCount: 0,
            finalMonsterCount: 0,
          ),
          loot: const {},
          sent: const {},
          survivorsIntact: const {},
          wounded: const {},
          dead: const {},
        ),
        TurnEndEntry(
          turn: 4,
          changes: const [],
          deactivatedBuildings: const [],
          lostUnits: const {},
        ),
      ];
    });

    test('HistoryFilter.all returns every entry', () {
      expect(applyHistoryFilter(entries, HistoryFilter.all).length, 7);
    });

    test('HistoryFilter.combat keeps only combat entries', () {
      final filtered = applyHistoryFilter(entries, HistoryFilter.combat);
      expect(filtered.length, 1);
      expect(filtered.single, isA<CombatEntry>());
    });

    test('HistoryFilter.building keeps only building entries', () {
      final filtered = applyHistoryFilter(entries, HistoryFilter.building);
      expect(filtered.length, 1);
      expect(filtered.single, isA<BuildingEntry>());
    });

    test('HistoryFilter.research keeps only research entries', () {
      final filtered = applyHistoryFilter(entries, HistoryFilter.research);
      expect(filtered.length, 1);
      expect(filtered.single, isA<ResearchEntry>());
    });

    test('HistoryFilter.other groups recruit/explore/collect/turnEnd', () {
      final filtered = applyHistoryFilter(entries, HistoryFilter.other);
      expect(filtered.length, 4);
      expect(filtered.whereType<RecruitEntry>(), hasLength(1));
      expect(filtered.whereType<ExploreEntry>(), hasLength(1));
      expect(filtered.whereType<CollectEntry>(), hasLength(1));
      expect(filtered.whereType<TurnEndEntry>(), hasLength(1));
    });
  });

  group('HistoryFilterLabel', () {
    test('exposes French labels for every value', () {
      expect(HistoryFilter.all.label, 'Tous');
      expect(HistoryFilter.combat.label, 'Combats');
      expect(HistoryFilter.building.label, 'Construction');
      expect(HistoryFilter.research.label, 'Recherche');
      expect(HistoryFilter.other.label, 'Autres');
    });
  });
}
