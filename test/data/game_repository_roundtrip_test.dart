import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import 'game_repository_fight_persistence_helper.dart';

const _boxName = 'games';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_hive_test_');
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

  Player buildPlayer() {
    final player = Player.withBase(
      name: 'Nemo',
      baseX: 7,
      baseY: 9,
      mapWidth: 20,
      mapHeight: 20,
      id: 'human-uuid',
    );
    player.resources[ResourceType.algae] = Resource(
      type: ResourceType.algae,
      amount: 777,
      maxStorage: 5000,
    );
    player.resources[ResourceType.pearl] = Resource(
      type: ResourceType.pearl,
      amount: 42,
      maxStorage: 100,
    );
    return player;
  }

  test('GameRepository round-trip preserves player state', () async {
    final originalPlayer = buildPlayer();
    final originalRevealed = originalPlayer.revealedCells;
    final original = Game.singlePlayer(originalPlayer);

    await repository.save(original);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final reloaded = GameRepository().loadAll();

    expect(reloaded, hasLength(1));
    final loaded = reloaded.first;
    final loadedPlayer = loaded.humanPlayer;

    expect(loaded.humanPlayerId, 'human-uuid');
    expect(loadedPlayer.id, 'human-uuid');
    expect(loadedPlayer.name, 'Nemo');
    expect(loadedPlayer.baseX, 7);
    expect(loadedPlayer.baseY, 9);
    expect(loadedPlayer.resources[ResourceType.algae]!.amount, 777);
    expect(loadedPlayer.resources[ResourceType.pearl]!.amount, 42);
    expect(loadedPlayer.resources[ResourceType.coral]!.amount, 300);
    expect(loadedPlayer.revealedCells, originalRevealed);
    expect(loadedPlayer.revealedCells, isNotEmpty);
    expect(loaded.turn, original.turn);
    expect(
      loaded.createdAt.millisecondsSinceEpoch,
      original.createdAt.millisecondsSinceEpoch,
    );
  });
}
