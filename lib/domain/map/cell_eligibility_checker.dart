import '../game/player.dart';
import 'game_map.dart';
import 'grid_position.dart';

class CellEligibilityChecker {
  static bool isEligible(
    GameMap map, Player player, int x, int y, {int level = 1,
  }) {
    if (level == 1 && x == player.baseX && y == player.baseY) {
      return false;
    }

    final revealed = player.revealedCellsSetOnLevel(level);

    // Revealed cells are eligible
    if (revealed.contains(GridPosition(x: x, y: y))) return true;

    // Unrevealed cells adjacent to a revealed cell are eligible
    return _hasRevealedNeighbor(map, revealed, x, y);
  }

  static bool _hasRevealedNeighbor(
    GameMap map,
    Set<GridPosition> revealed,
    int x,
    int y,
  ) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || nx >= map.width || ny < 0 || ny >= map.height) {
          continue;
        }
        if (revealed.contains(GridPosition(x: nx, y: ny))) return true;
      }
    }
    return false;
  }
}
