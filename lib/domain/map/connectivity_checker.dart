import 'map_cell.dart';
import 'terrain_type.dart';

class ConnectivityChecker {
  static void ensureConnectivity(
    List<MapCell> cells,
    int width,
    int height,
    int baseX,
    int baseY,
  ) {
    final reachable = _bfs(cells, width, height, baseX, baseY);
    final edges = [
      [for (var x = 0; x < width; x++) (x, 0)],
      [for (var x = 0; x < width; x++) (x, height - 1)],
      [for (var y = 0; y < height; y++) (0, y)],
      [for (var y = 0; y < height; y++) (width - 1, y)],
    ];
    for (final edge in edges) {
      if (edge.any((p) => reachable[p.$2 * width + p.$1])) continue;
      _carvePathToEdge(cells, width, height, baseX, baseY, edge);
      reachable.setAll(0, _bfs(cells, width, height, baseX, baseY));
    }
  }

  static List<bool> _bfs(
    List<MapCell> cells,
    int width, int height,
    int startX, int startY,
  ) {
    final visited = List.filled(width * height, false);
    final queue = [(startX, startY)];
    visited[startY * width + startX] = true;
    while (queue.isNotEmpty) {
      final (cx, cy) = queue.removeAt(0);
      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nx = cx + dx, ny = cy + dy;
        if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
        final idx = ny * width + nx;
        if (visited[idx]) continue;
        if (cells[idx].terrain == TerrainType.rock) continue;
        visited[idx] = true;
        queue.add((nx, ny));
      }
    }
    return visited;
  }

  static void _carvePathToEdge(
    List<MapCell> cells,
    int width, int height,
    int baseX, int baseY,
    List<(int, int)> edge,
  ) {
    final visited = List.filled(width * height, false);
    final parent = List.filled(width * height, -1);
    final queue = [(baseX, baseY)];
    visited[baseY * width + baseX] = true;
    final edgeSet = {for (final p in edge) p.$2 * width + p.$1};

    while (queue.isNotEmpty) {
      final (cx, cy) = queue.removeAt(0);
      final ci = cy * width + cx;
      if (edgeSet.contains(ci)) {
        var idx = ci;
        while (idx != -1) {
          if (cells[idx].terrain == TerrainType.rock) {
            cells[idx] = MapCell(terrain: TerrainType.plain);
          }
          idx = parent[idx];
        }
        return;
      }
      for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
        final nx = cx + dx, ny = cy + dy;
        if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
        final ni = ny * width + nx;
        if (visited[ni]) continue;
        visited[ni] = true;
        parent[ni] = ci;
        queue.add((nx, ny));
      }
    }
  }
}
