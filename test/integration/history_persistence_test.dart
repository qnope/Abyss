import 'dart:io';
import 'dart:math';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/unlock_branch_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/history/history_entry_category.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../data/game_repository_fight_persistence_helper.dart';
import 'history_integration_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_history_persist_');
    Hive.init(tempDir.path);
    registerFightPersistenceAdapters();
    await Hive.openBox<Game>(_boxName);
    repository = GameRepository();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(_boxName);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('history entries survive a Hive round-trip', () async {
    final game = buildHistoryScenarioGame();
    final player = game.humanPlayer;
    final executor = ActionExecutor();

    // Run a compact but representative subset of the scenario so the
    // resulting history contains a CombatEntry (the only entry type that
    // carries a FightResult) along with a few simpler entries.
    game.turn = 1;
    executor.execute(
      UpgradeBuildingAction(buildingType: BuildingType.headquarters),
      game,
      player,
    );

    game.turn = 2;
    executor.execute(
      UnlockBranchAction(branch: TechBranch.military),
      game,
      player,
    );

    game.turn = 3;
    executor.execute(
      CollectTreasureAction(targetX: 4, targetY: 3, random: Random(0)),
      game,
      player,
    );

    game.turn = 4;
    final fightResult = executor.execute(
      FightMonsterAction(
        targetX: 2,
        targetY: 3,
        selectedUnits: const {UnitType.harpoonist: 15},
        random: Random(0),
      ),
      game,
      player,
    );
    expect(fightResult.isSuccess, isTrue);

    game.turn = 5;
    executor.execute(EndTurnAction(), game, player);

    expect(player.historyEntries.length, 5);
    final originalCombat =
        player.historyEntries.firstWhere((e) => e is CombatEntry) as CombatEntry;
    final originalTurnCount = originalCombat.fightResult.turnCount;
    final originalTurnSummaryCount =
        originalCombat.fightResult.turnSummaries.length;
    expect(originalTurnSummaryCount, greaterThan(0),
        reason: 'Combat should have at least one turn summary');

    await repository.save(game);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final reloaded = GameRepository().loadAll();
    expect(reloaded, hasLength(1));
    final loaded = reloaded.first;
    final loadedPlayer = loaded.humanPlayer;

    // Same length and same per-entry category/turn.
    expect(loadedPlayer.historyEntries.length, player.historyEntries.length);
    for (var i = 0; i < player.historyEntries.length; i++) {
      final before = player.historyEntries[i];
      final after = loadedPlayer.historyEntries[i];
      expect(after.category, before.category);
      expect(after.turn, before.turn);
      expect(after.runtimeType, before.runtimeType);
    }

    // The combat entry round-trips fightResult.turnCount and turnSummaries.
    final loadedCombat = loadedPlayer.historyEntries.firstWhere(
      (e) => e.category == HistoryEntryCategory.combat,
    ) as CombatEntry;
    expect(loadedCombat.fightResult.turnCount, originalTurnCount);
    expect(
      loadedCombat.fightResult.turnSummaries.length,
      originalTurnSummaryCount,
    );
    expect(loadedCombat.victory, originalCombat.victory);
    expect(loadedCombat.targetX, originalCombat.targetX);
    expect(loadedCombat.targetY, originalCombat.targetY);
  });
}
