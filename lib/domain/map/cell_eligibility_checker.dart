import 'game_map.dart';

class CellEligibilityChecker {
  static bool isEligible(GameMap map, int x, int y) {
    // Base cell is never eligible
    if (x == map.playerBaseX && y == map.playerBaseY) return false;

    final cell = map.cellAt(x, y);

    // Revealed cells are eligible
    if (cell.isRevealed) return true;

    // Unrevealed cells adjacent to a revealed cell are eligible
    return _hasRevealedNeighbor(map, x, y);
  }

  static bool _hasRevealedNeighbor(GameMap map, int x, int y) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || nx >= map.width || ny < 0 || ny >= map.height) {
          continue;
        }
        if (map.cellAt(nx, ny).isRevealed) return true;
      }
    }
    return false;
  }
}
