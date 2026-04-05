import 'dart:math';
import 'connectivity_checker.dart';
import 'map_cell.dart';
import 'terrain_type.dart';

class TerrainGenerator {
  static List<MapCell> generate({
    required int width,
    required int height,
    required Random random,
    required int baseX,
    required int baseY,
  }) {
    final cells = List.generate(
      width * height,
      (_) => MapCell(terrain: TerrainType.reef),
    );

    cells[baseY * width + baseX] = MapCell(terrain: TerrainType.plain);
    _assignNeighbors(cells, width, height, baseX, baseY, random);
    _assignRemaining(cells, width, height, baseX, baseY, random);
    ConnectivityChecker.ensureConnectivity(
      cells, width, height, baseX, baseY,
    );
    return cells;
  }

  static void _assignNeighbors(
    List<MapCell> cells,
    int width, int height,
    int baseX, int baseY,
    Random random,
  ) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = baseX + dx;
        final ny = baseY + dy;
        if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
        final terrain = random.nextBool()
            ? TerrainType.reef
            : TerrainType.plain;
        cells[ny * width + nx] = MapCell(terrain: terrain);
      }
    }
  }

  static void _assignRemaining(
    List<MapCell> cells,
    int width, int height,
    int baseX, int baseY,
    Random random,
  ) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if ((x - baseX).abs() <= 1 && (y - baseY).abs() <= 1) continue;
        final roll = random.nextDouble();
        final TerrainType terrain;
        if (roll < 0.40) {
          terrain = TerrainType.reef;
        } else if (roll < 0.70) {
          terrain = TerrainType.plain;
        } else if (roll < 0.85) {
          terrain = TerrainType.rock;
        } else {
          terrain = TerrainType.fault;
        }
        cells[y * width + x] = MapCell(terrain: terrain);
      }
    }
  }
}
