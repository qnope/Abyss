import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

const int kMapSize = 20;
const int kKernelX = 10;
const int kKernelY = 10;
const String kPlayerId = 'end-game-player';

GameMap buildLevel3Map() {
  final cells = List.generate(
    kMapSize * kMapSize,
    (_) => MapCell(terrain: TerrainType.plain),
  );
  cells[kKernelY * kMapSize + kKernelX] = MapCell(
    terrain: TerrainType.plain,
    content: CellContentType.volcanicKernel,
  );
  return GameMap(
    width: kMapSize,
    height: kMapSize,
    cells: cells,
    seed: 42,
  );
}

Player buildEndGamePlayer() {
  return Player(
    id: kPlayerId,
    name: 'Nemo',
    resources: {
      for (final t in ResourceType.values)
        t: Resource(
          type: t,
          amount: t == ResourceType.pearl ? 9999 : 999999,
          maxStorage: t == ResourceType.pearl ? 99999 : 9999999,
        ),
    },
    buildings: {
      for (final t in BuildingType.values)
        t: Building(type: t, level: 0),
    },
    unitsPerLevel: {
      3: {
        for (final t in UnitType.values)
          t: Unit(type: t, count: 0),
      },
    },
  );
}

({Game game, Player player}) buildEndGameScenario() {
  final player = buildEndGamePlayer();
  player.buildings[BuildingType.headquarters]!.level = 10;
  player.unitsOnLevel(3)[UnitType.abyssAdmiral]!.count = 50;
  player.unitsOnLevel(3)[UnitType.domeBreaker]!.count = 200;

  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {3: buildLevel3Map()},
  );
  return (game: game, player: player);
}
