import 'dart:io';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../data/game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

Player _buildFifoPlayer() {
  return Player(
    id: 'fifo-uuid',
    name: 'Fifo',
    resources: {
      ResourceType.algae:
          Resource(type: ResourceType.algae, amount: 99999, maxStorage: 99999),
      ResourceType.coral:
          Resource(type: ResourceType.coral, amount: 99999, maxStorage: 99999),
      ResourceType.ore:
          Resource(type: ResourceType.ore, amount: 99999, maxStorage: 99999),
      ResourceType.energy:
          Resource(type: ResourceType.energy, amount: 99999, maxStorage: 99999),
      ResourceType.pearl:
          Resource(type: ResourceType.pearl, amount: 9999, maxStorage: 9999),
    },
    buildings: {
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: 0),
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_history_fifo_');
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

  test('150 successful actions cap history at 100, then persist verbatim',
      () async {
    final player = _buildFifoPlayer();
    final game = Game(
      humanPlayerId: player.id,
      players: {player.id: player},
      turn: 1,
    );
    final executor = ActionExecutor();
    final action =
        UpgradeBuildingAction(buildingType: BuildingType.headquarters);

    for (var i = 0; i < 150; i++) {
      // Reset level so the upgrade re-succeeds, top up resources, and
      // bump the turn so the entry gets a unique, monotonically increasing
      // turn number that we can assert on below.
      player.buildings[BuildingType.headquarters]!.level = 0;
      player.resources[ResourceType.algae]!.amount = 99999;
      player.resources[ResourceType.coral]!.amount = 99999;
      player.resources[ResourceType.ore]!.amount = 99999;
      player.resources[ResourceType.energy]!.amount = 99999;
      player.resources[ResourceType.pearl]!.amount = 99999;
      game.turn = i + 1;

      final result = executor.execute(action, game, player);
      expect(result.isSuccess, isTrue, reason: 'Iteration $i should succeed');
    }

    expect(player.historyEntries.length, 100);
    // With 150 successful entries (turn 1..150) and a cap of 100 FIFO,
    // the first kept entry is turn 51 and the last is turn 150.
    final firstEntry = player.historyEntries.first as BuildingEntry;
    final lastEntry = player.historyEntries.last as BuildingEntry;
    expect(firstEntry.turn, 51);
    expect(lastEntry.turn, 150);

    // Persist and reload -- the 100-entry FIFO order must survive.
    await repository.save(game);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final reloaded = GameRepository().loadAll();
    expect(reloaded, hasLength(1));
    final loadedEntries = reloaded.first.humanPlayer.historyEntries;
    expect(loadedEntries.length, 100);

    for (var i = 0; i < 100; i++) {
      final before = player.historyEntries[i] as BuildingEntry;
      final after = loadedEntries[i] as BuildingEntry;
      expect(after.turn, before.turn);
      expect(after.buildingType, before.buildingType);
      expect(after.newLevel, before.newLevel);
    }
  });
}
