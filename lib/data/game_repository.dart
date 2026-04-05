import 'package:hive_flutter/hive_flutter.dart';
import '../domain/building/building.dart';
import '../domain/building/building_type.dart';
import '../domain/map/cell_content_type.dart';
import '../domain/map/exploration_order.dart';
import '../domain/game/game.dart';
import '../domain/map/game_map.dart';
import '../domain/map/grid_position.dart';
import '../domain/map/map_cell.dart';
import '../domain/map/monster_difficulty.dart';
import '../domain/game/player.dart';
import '../domain/resource/resource.dart';
import '../domain/resource/resource_type.dart';
import '../domain/tech/tech_branch.dart';
import '../domain/tech/tech_branch_state.dart';
import '../domain/map/terrain_type.dart';
import '../domain/unit/unit.dart';
import '../domain/unit/unit_type.dart';

class GameRepository {
  static const _boxName = 'games';

  static Future<void> initialize() async {
    await Hive.initFlutter();
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
    Hive.registerAdapter(MapCellAdapter());
    Hive.registerAdapter(GameMapAdapter());
    Hive.registerAdapter(GridPositionAdapter());
    Hive.registerAdapter(ExplorationOrderAdapter());
    Hive.registerAdapter(GameAdapter());
    try {
      await Hive.openBox<Game>(_boxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(_boxName);
      await Hive.openBox<Game>(_boxName);
    }
  }

  Box<Game> get _box => Hive.box<Game>(_boxName);

  Future<void> save(Game game) async {
    if (game.isInBox) {
      await game.save();
    } else {
      await _box.add(game);
    }
  }

  List<Game> loadAll() {
    return _box.values.toList();
  }

  Future<void> delete(int index) async {
    await _box.deleteAt(index);
  }
}
