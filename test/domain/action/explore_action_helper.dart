import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Builds a 7x7 map, plain terrain everywhere.
GameMap buildExploreTestMap() {
  final cells = <MapCell>[];
  for (var y = 0; y < 7; y++) {
    for (var x = 0; x < 7; x++) {
      cells.add(MapCell(terrain: TerrainType.plain));
    }
  }
  return GameMap(width: 7, height: 7, cells: cells, seed: 42);
}

int _chebyshev(int x1, int y1, int x2, int y2) {
  final dx = (x1 - x2).abs();
  final dy = (y1 - y2).abs();
  return dx > dy ? dx : dy;
}

/// Pre-reveal for the player all cells at Chebyshev distance <= 1 from base.
List<GridPosition> _initialRevealedCells(int baseX, int baseY) {
  final cells = <GridPosition>[];
  for (var y = 0; y < 7; y++) {
    for (var x = 0; x < 7; x++) {
      if (_chebyshev(x, y, baseX, baseY) <= 1) {
        cells.add(GridPosition(x: x, y: y));
      }
    }
  }
  return cells;
}

({Game game, Player player}) createExploreScenario({
  int scoutCount = 3,
  GameMap? gameMap,
  String playerId = 'test-uuid',
}) {
  final player = Player(
    id: playerId,
    name: 'Test',
    baseX: 3,
    baseY: 3,
    unitsPerLevel: {1: {
      for (final type in UnitType.values)
        type: Unit(
          type: type,
          count: type == UnitType.scout ? scoutCount : 0,
        ),
    }},
    revealedCellsPerLevel: {1: _initialRevealedCells(3, 3)},
  );
  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    gameMap: gameMap ?? buildExploreTestMap(),
  );
  return (game: game, player: player);
}
