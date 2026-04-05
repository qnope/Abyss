import 'package:hive_flutter/hive_flutter.dart';
import '../domain/building.dart';
import '../domain/building_type.dart';
import '../domain/game.dart';
import '../domain/game_map.dart';
import '../domain/map_tile.dart';
import '../domain/player.dart';
import '../domain/resource.dart';
import '../domain/resource_type.dart';
import '../domain/tech_branch.dart';
import '../domain/tech_branch_state.dart';
import '../domain/terrain_type.dart';
import '../domain/tile_content.dart';
import '../domain/unit.dart';
import '../domain/unit_type.dart';

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
    Hive.registerAdapter(TileContentAdapter());
    Hive.registerAdapter(MapTileAdapter());
    Hive.registerAdapter(GameMapAdapter());
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
