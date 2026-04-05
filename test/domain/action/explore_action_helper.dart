import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Builds a 7×7 map with base at (3,3).
/// Cells at Chebyshev distance ≤ 1 from base are revealed.
GameMap buildTestMap() {
  final cells = <MapCell>[];
  for (var y = 0; y < 7; y++) {
    for (var x = 0; x < 7; x++) {
      final dist = _chebyshev(x, y, 3, 3);
      cells.add(MapCell(
        terrain: TerrainType.plain,
        isRevealed: dist <= 1,
      ));
    }
  }
  return GameMap(
    width: 7,
    height: 7,
    cells: cells,
    playerBaseX: 3,
    playerBaseY: 3,
    seed: 42,
  );
}

int _chebyshev(int x1, int y1, int x2, int y2) {
  final dx = (x1 - x2).abs();
  final dy = (y1 - y2).abs();
  return dx > dy ? dx : dy;
}

Game createExploreGame({int scoutCount = 3, GameMap? gameMap}) {
  return Game(
    player: Player(name: 'Test'),
    units: {
      for (final type in UnitType.values)
        type: Unit(
          type: type,
          count: type == UnitType.scout ? scoutCount : 0,
        ),
    },
    gameMap: gameMap ?? buildTestMap(),
  );
}
