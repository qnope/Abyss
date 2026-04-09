import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'history_adapters_test';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<HistoryEntry> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_history_adapters_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    box = await Hive.openBox<HistoryEntry>(_boxName);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<T> roundTrip<T extends HistoryEntry>(T entry) async {
    await box.add(entry);
    await box.close();
    Hive.init(tempDir.path);
    box = await Hive.openBox<HistoryEntry>(_boxName);
    return box.values.last as T;
  }

  test('BuildingEntry survives Hive round-trip', () async {
    final original = BuildingEntry(
      turn: 3,
      buildingType: BuildingType.algaeFarm,
      newLevel: 2,
      subtitle: 'coût réduit',
    );

    final loaded = await roundTrip(original);

    expect(loaded.turn, 3);
    expect(loaded.category, HistoryEntryCategory.building);
    expect(loaded.title, original.title);
    expect(loaded.subtitle, 'coût réduit');
    expect(loaded.buildingType, BuildingType.algaeFarm);
    expect(loaded.newLevel, 2);
  });

  test('ResearchEntry survives Hive round-trip', () async {
    final original = ResearchEntry(
      turn: 4,
      branch: TechBranch.military,
      isUnlock: false,
      newLevel: 2,
    );

    final loaded = await roundTrip(original);

    expect(loaded.turn, 4);
    expect(loaded.category, HistoryEntryCategory.research);
    expect(loaded.branch, TechBranch.military);
    expect(loaded.isUnlock, isFalse);
    expect(loaded.newLevel, 2);
    expect(loaded.title, original.title);
  });

  test('RecruitEntry survives Hive round-trip', () async {
    final original = RecruitEntry(
      turn: 5,
      unitType: UnitType.scout,
      quantity: 4,
    );

    final loaded = await roundTrip(original);

    expect(loaded.turn, 5);
    expect(loaded.category, HistoryEntryCategory.recruit);
    expect(loaded.unitType, UnitType.scout);
    expect(loaded.quantity, 4);
    expect(loaded.title, original.title);
  });

  test('ExploreEntry survives Hive round-trip', () async {
    final original = ExploreEntry(turn: 6, targetX: 2, targetY: 7);

    final loaded = await roundTrip(original);

    expect(loaded.turn, 6);
    expect(loaded.category, HistoryEntryCategory.explore);
    expect(loaded.targetX, 2);
    expect(loaded.targetY, 7);
    expect(loaded.title, 'Exploration (2, 7)');
  });

  test('CollectEntry survives Hive round-trip with gains map', () async {
    final original = CollectEntry(
      turn: 8,
      targetX: 1,
      targetY: 2,
      gains: const {ResourceType.algae: 50, ResourceType.pearl: 3},
    );

    final loaded = await roundTrip(original);

    expect(loaded.turn, 8);
    expect(loaded.category, HistoryEntryCategory.collect);
    expect(loaded.targetX, 1);
    expect(loaded.targetY, 2);
    expect(loaded.gains[ResourceType.algae], 50);
    expect(loaded.gains[ResourceType.pearl], 3);
  });

  test('CombatEntry round-trips full FightResult with summaries', () async {
    final playerA = Combatant(
      side: CombatSide.player,
      typeKey: 'scout',
      maxHp: 10,
      atk: 3,
      def: 1,
      currentHp: 6,
    );
    final playerB = Combatant(
      side: CombatSide.player,
      typeKey: 'harpoonist',
      maxHp: 12,
      atk: 5,
      def: 2,
    );
    final monsterA = Combatant(
      side: CombatSide.monster,
      typeKey: 'monsterL2',
      maxHp: 8,
      atk: 2,
      def: 1,
    );
    final monsterB = Combatant(
      side: CombatSide.monster,
      typeKey: 'monsterL2',
      maxHp: 8,
      atk: 2,
      def: 1,
      currentHp: 0,
    );

    final fight = FightResult(
      winner: CombatSide.player,
      turnCount: 1,
      turnSummaries: const [
        FightTurnSummary(
          turnNumber: 1,
          attacksPlayed: 4,
          critCount: 1,
          damageDealtByPlayer: 9,
          damageDealtByMonster: 4,
          playerAliveAtEnd: 2,
          monsterAliveAtEnd: 1,
          playerHpAtEnd: 18,
          monsterHpAtEnd: 4,
        ),
      ],
      initialPlayerCombatants: [playerA, playerB],
      finalPlayerCombatants: [playerA, playerB],
      initialMonsterCount: 2,
      finalMonsterCount: 1,
    );

    final original = CombatEntry(
      turn: 9,
      victory: true,
      targetX: 3,
      targetY: 4,
      lair: const MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 2,
      ),
      fightResult: fight,
      loot: const {ResourceType.algae: 25, ResourceType.ore: 4},
      sent: const {UnitType.scout: 1, UnitType.harpoonist: 1},
      survivorsIntact: const {UnitType.harpoonist: 1},
      wounded: const {UnitType.scout: 1},
      dead: const {},
    );
    // Ignore monster clones in test since they are not in FightResult lists.
    expect(monsterA.typeKey, 'monsterL2');
    expect(monsterB.currentHp, 0);

    final loaded = await roundTrip(original);

    expect(loaded.turn, 9);
    expect(loaded.category, HistoryEntryCategory.combat);
    expect(loaded.victory, isTrue);
    expect(loaded.targetX, 3);
    expect(loaded.targetY, 4);
    expect(loaded.lair.difficulty, MonsterDifficulty.medium);
    expect(loaded.lair.unitCount, 2);
    expect(loaded.fightResult.winner, CombatSide.player);
    expect(loaded.fightResult.turnCount, 1);
    expect(loaded.fightResult.turnSummaries, hasLength(1));
    final summary = loaded.fightResult.turnSummaries.first;
    expect(summary.attacksPlayed, 4);
    expect(summary.critCount, 1);
    expect(summary.damageDealtByPlayer, 9);
    expect(summary.playerHpAtEnd, 18);
    expect(loaded.fightResult.initialPlayerCombatants, hasLength(2));
    expect(
      loaded.fightResult.initialPlayerCombatants.first.typeKey,
      'scout',
    );
    expect(
      loaded.fightResult.initialPlayerCombatants.first.currentHp,
      6,
    );
    expect(loaded.fightResult.initialMonsterCount, 2);
    expect(loaded.fightResult.finalMonsterCount, 1);
    expect(loaded.loot[ResourceType.algae], 25);
    expect(loaded.sent[UnitType.scout], 1);
    expect(loaded.survivorsIntact[UnitType.harpoonist], 1);
    expect(loaded.wounded[UnitType.scout], 1);
    expect(loaded.dead, isEmpty);
  });

  test('TurnEndEntry round-trips TurnResourceChange list', () async {
    final original = TurnEndEntry(
      turn: 10,
      changes: const [
        TurnResourceChange(
          type: ResourceType.algae,
          produced: 30,
          consumed: 5,
          wasCapped: false,
          beforeAmount: 100,
          afterAmount: 125,
        ),
        TurnResourceChange(
          type: ResourceType.energy,
          produced: 12,
          wasCapped: true,
          beforeAmount: 50,
          afterAmount: 50,
        ),
      ],
      deactivatedBuildings: const [BuildingType.coralMine],
      lostUnits: const {UnitType.scout: 1},
    );

    final loaded = await roundTrip(original);

    expect(loaded.turn, 10);
    expect(loaded.category, HistoryEntryCategory.turnEnd);
    expect(loaded.changes, hasLength(2));
    expect(loaded.changes.first.type, ResourceType.algae);
    expect(loaded.changes.first.produced, 30);
    expect(loaded.changes.first.consumed, 5);
    expect(loaded.changes.first.wasCapped, isFalse);
    expect(loaded.changes.first.beforeAmount, 100);
    expect(loaded.changes.first.afterAmount, 125);
    expect(loaded.changes[1].type, ResourceType.energy);
    expect(loaded.changes[1].wasCapped, isTrue);
    expect(loaded.deactivatedBuildings, [BuildingType.coralMine]);
    expect(loaded.lostUnits[UnitType.scout], 1);
  });
}
