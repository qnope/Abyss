import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';

/// Builds a 5x5 map with base at (2,2).
/// Cell at (1,1) set with the specified content type and optional fields.
GameMap buildCollectTestMap({
  CellContentType content = CellContentType.resourceBonus,
  MonsterLair? lair,
  String? collectedBy,
}) {
  final cells = <MapCell>[];
  for (var y = 0; y < 5; y++) {
    for (var x = 0; x < 5; x++) {
      if (x == 1 && y == 1) {
        cells.add(MapCell(
          terrain: TerrainType.plain,
          content: content,
          lair: lair,
          collectedBy: collectedBy,
        ));
      } else {
        cells.add(MapCell(terrain: TerrainType.plain));
      }
    }
  }
  return GameMap(width: 5, height: 5, cells: cells, seed: 42);
}

/// Build a player with all 5x5 cells pre-revealed, base at (2,2).
Player buildCollectTestPlayer({String id = 'test-uuid'}) {
  final revealed = <GridPosition>[
    for (var y = 0; y < 5; y++)
      for (var x = 0; x < 5; x++) GridPosition(x: x, y: y),
  ];
  return Player(
    id: id,
    name: 'Test',
    baseX: 2,
    baseY: 2,
    revealedCellsPerLevel: {1: revealed},
  );
}

({Game game, Player player}) createCollectScenario({
  CellContentType content = CellContentType.resourceBonus,
  MonsterLair? lair,
  String? collectedBy,
  String playerId = 'test-uuid',
}) {
  final player = buildCollectTestPlayer(id: playerId);
  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    levels: {1: buildCollectTestMap(
      content: content,
      lair: lair,
      collectedBy: collectedBy,
    )},
  );
  return (game: game, player: player);
}
