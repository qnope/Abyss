import 'dart:io';
import 'dart:math';

import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_fight_hive_');
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

  test('victorious fight persists through Hive round-trip', () async {
    final Game game = buildFightPersistenceGame();
    final player = game.humanPlayer;

    final result = FightMonsterAction(
      targetX: 1,
      targetY: 1,
      selectedUnits: {UnitType.harpoonist: 10},
      random: Random(0),
    ).execute(game, player) as FightMonsterResult;
    expect(result.victory, isTrue);

    final Map<ResourceType, int> expectedAmounts = <ResourceType, int>{
      for (final entry in player.resources.entries)
        entry.key: entry.value.amount,
    };

    await repository.save(game);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final List<Game> reloaded = GameRepository().loadAll();

    expect(reloaded, hasLength(1));
    final Game loaded = reloaded.first;
    final MapCell loadedCell = loaded.gameMap!.cellAt(1, 1);
    expect(loadedCell.isCollected, isTrue);
    expect(loadedCell.collectedBy, player.id);
    expect(loadedCell.content, CellContentType.monsterLair);
    expect(loadedCell.lair, isNotNull,
        reason: 'Collected lair composition must survive persistence');
    expect(loadedCell.lair!.difficulty, MonsterDifficulty.easy);
    expect(loadedCell.lair!.unitCount, 2);

    for (final entry in expectedAmounts.entries) {
      expect(
        loaded.humanPlayer.resources[entry.key]!.amount,
        entry.value,
        reason: 'Resource ${entry.key} must survive persistence',
      );
    }
  });
}
