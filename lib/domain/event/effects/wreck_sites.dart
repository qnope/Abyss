import '../../game/player.dart';
import '../../map/cell_content_type.dart';
import '../../map/cell_eligibility_checker.dart';
import '../../map/game_map.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';

/// Cells where a wreck may sink: hidden from the player, empty, and just
/// at the edge of the explored area, so a scout can explore them.
abstract final class WreckSites {
  /// The wreck sinks on level 1 only.
  static const int level = 1;

  /// Sites of [map] for [player], in row-major order.
  ///
  /// Walks the neighbours of the revealed cells only, so the search grows
  /// with the explored area, not with the map.
  static List<GridPosition> of(GameMap map, Player player) {
    final List<GridPosition> revealed = player.revealedCellsOnLevel(level);
    final Set<GridPosition> known = revealed.toSet();
    final Set<int> visited = <int>{};
    final List<int> sites = <int>[];
    for (final GridPosition p in revealed) {
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          final int x = p.x + dx;
          final int y = p.y + dy;
          if (x < 0 || x >= map.width || y < 0 || y >= map.height) continue;
          final int index = y * map.width + x;
          if (!visited.add(index)) continue;
          if (_fits(map, player, known, x, y)) sites.add(index);
        }
      }
    }
    sites.sort();
    return <GridPosition>[
      for (final int i in sites)
        GridPosition(x: i % map.width, y: i ~/ map.width),
    ];
  }

  static bool _fits(
    GameMap map,
    Player player,
    Set<GridPosition> known,
    int x,
    int y,
  ) {
    if (known.contains(GridPosition(x: x, y: y))) return false;
    final MapCell cell = map.cellAt(x, y);
    return cell.content == CellContentType.empty &&
        !cell.isCollected &&
        CellEligibilityChecker.isEligibleAmong(map, player, known, x, y);
  }
}
