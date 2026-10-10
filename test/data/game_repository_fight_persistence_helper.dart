import 'package:abyss/hive_registrar.g.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:hive_ce/hive.dart';

void registerFightPersistenceAdapters() {
  if (Hive.isAdapterRegistered(0)) return;
  Hive.registerAdapters();
}

GameMap buildFightPersistenceMap() {
  final cells = <MapCell>[];
  for (var y = 0; y < 5; y++) {
    for (var x = 0; x < 5; x++) {
      if (x == 1 && y == 1) {
        cells.add(
          MapCell(
            terrain: TerrainType.plain,
            content: CellContentType.monsterLair,
            lair: const MonsterLair(
              difficulty: MonsterDifficulty.easy,
              unitCount: 2,
            ),
          ),
        );
      } else {
        cells.add(MapCell(terrain: TerrainType.plain));
      }
    }
  }
  return GameMap(width: 5, height: 5, cells: cells, seed: 99);
}

Game buildFightPersistenceGame() {
  final Player player = Player(
    id: 'persist-uuid',
    name: 'Persist',
    baseX: 2,
    baseY: 2,
  );
  player.unitsOnLevel(1)[UnitType.harpoonist]!.count = 15;
  player.addRevealedCell(1, GridPosition(x: 1, y: 1));
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {1: buildFightPersistenceMap()},
  );
}
