import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:abyss/data/game_repository.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
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
  Hive.registerAdapter(GameStatusAdapter());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late GameRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('abyss_citadel_hive_');
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

  test('Coral Citadel level and stats survive Hive round-trip', () async {
    final player = Player(id: 'citadel-uuid', name: 'Defender');
    player.buildings[BuildingType.headquarters]!.level = 7;
    player.buildings[BuildingType.coralCitadel]!.level = 3;
    player.buildings[BuildingType.solarPanel]!.level = 4;
    player.resources[ResourceType.energy] = Resource(
      type: ResourceType.energy,
      amount: 10,
      maxStorage: 1000,
    );
    player.resources[ResourceType.pearl] = Resource(
      type: ResourceType.pearl,
      amount: 42,
      maxStorage: 100,
    );
    final original = Game.singlePlayer(player);

    await repository.save(original);
    await Hive.close();

    Hive.init(tempDir.path);
    await Hive.openBox<Game>(_boxName);
    final reloaded = GameRepository().loadAll();

    expect(reloaded, hasLength(1));
    final loadedPlayer = reloaded.first.humanPlayer;
    expect(loadedPlayer.buildings[BuildingType.coralCitadel]!.level, 3);
    expect(loadedPlayer.buildings[BuildingType.headquarters]!.level, 7);
    expect(loadedPlayer.buildings[BuildingType.solarPanel]!.level, 4);
    expect(loadedPlayer.buildings[BuildingType.algaeFarm]!.level, 0);
    expect(loadedPlayer.buildings[BuildingType.coralMine]!.level, 0);
    expect(loadedPlayer.buildings[BuildingType.oreExtractor]!.level, 0);
    expect(loadedPlayer.buildings[BuildingType.laboratory]!.level, 0);
    expect(loadedPlayer.buildings[BuildingType.barracks]!.level, 0);
    expect(loadedPlayer.resources[ResourceType.energy]!.amount, 10);
    expect(loadedPlayer.resources[ResourceType.pearl]!.amount, 42);
  });
}
