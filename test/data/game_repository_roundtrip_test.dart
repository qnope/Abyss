import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

const _boxName = 'games';

void _registerAdapters() {
  if (Hive.isAdapterRegistered(0)) return;
  Hive.registerAdapter(BuildingTypeAdapter());
  Hive.registerAdapter(BuildingAdapter());
  Hive.registerAdapter(ResourceTypeAdapter());
  Hive.registerAdapter(ResourceAdapter());
  Hive.registerAdapter(TechBranchAdapter());
  Hive.registerAdapter(TechBranchStateAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(UnitTypeAdapter());
  Hive.registerAdapter(UnitAdapter());
  Hive.registerAdapter(TerrainTypeAdapter());
  Hive.registerAdapter(CellContentTypeAdapter());
  Hive.registerAdapter(MonsterDifficultyAdapter());
  Hive.registerAdapter(MonsterLairAdapter());
  Hive.registerAdapter(MapCellAdapter());
  Hive.registerAdapter(GameMapAdapter());
  Hive.registerAdapter(GridPositionAdapter());
  Hive.registerAdapter(ExplorationOrderAdapter());
  Hive.registerAdapter(GameAdapter());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_hive_test_');
    Hive.init(tempDir.path);
    _registerAdapters();
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
    expect(loadedPlayer.resources[ResourceType.coral]!.amount, 80);
    expect(loadedPlayer.revealedCells, originalRevealed);
    expect(loadedPlayer.revealedCells, isNotEmpty);
    expect(loaded.turn, original.turn);
    expect(
      loaded.createdAt.millisecondsSinceEpoch,
      original.createdAt.millisecondsSinceEpoch,
    );
  });
}
