import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Plain [size] x [size] map, every cell empty but those of [contents].
GameMap wreckMap({
  int size = 9,
  Map<GridPosition, CellContentType> contents = const {},
}) => GameMap(
  width: size,
  height: size,
  seed: 7,
  cells: [
    for (var y = 0; y < size; y++)
      for (var x = 0; x < size; x++)
        MapCell(
          terrain: TerrainType.plain,
          content:
              contents[GridPosition(x: x, y: y)] ?? CellContentType.empty,
        ),
  ],
);

/// Cells at most [radius] away from ([cx], [cy]), in row-major order.
List<GridPosition> squareAround(int cx, int cy, int radius) => [
  for (var y = cy - radius; y <= cy + radius; y++)
    for (var x = cx - radius; x <= cx + radius; x++) GridPosition(x: x, y: y),
];

/// Hidden ring around the 3x3 square revealed by [wreckPlayer].
List<GridPosition> get wreckRing => [
  for (final p in squareAround(4, 4, 2))
    if ((p.x - 4).abs() == 2 || (p.y - 4).abs() == 2) p,
];

/// Player based at (4, 4) who revealed [revealed], by default the 3x3
/// square around the base, with [scouts] scouts on level 1. No draw is
/// scheduled before turn 100.
Player wreckPlayer({List<GridPosition>? revealed, int scouts = 1}) {
  final player = Player(
    id: 'p1',
    name: 'Test',
    baseX: 4,
    baseY: 4,
    revealedCellsPerLevel: {1: revealed ?? squareAround(4, 4, 1)},
    unitsPerLevel: {
      1: {
        for (final type in UnitType.values)
          type: Unit(type: type, count: type == UnitType.scout ? scouts : 0),
      },
    },
  );
  return player..eventState.schedule(100);
}

/// Single-player game of [player] on [map] during [turn].
Game wreckGame(Player player, {GameMap? map, int turn = 12}) =>
    Game.singlePlayer(player)
      ..levels = {1: map ?? wreckMap()}
      ..turn = turn;
