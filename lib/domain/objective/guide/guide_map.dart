import '../../fight/assault/assault_target.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/captured_base_finder.dart';
import '../../map/cell_content_type.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../map/transition_base.dart';
import '../../map/volcano_footprint.dart';
import 'guide_target.dart';

/// Finds on the maps of a game the cells the guide's halo points at: a
/// post to take, a post held, the kernel held.
abstract final class GuideMap {
  /// The cell of [level] holding the [target] still to take that
  /// [player] sees nearest to their base, the anchor for the kernel;
  /// `null` when they see none.
  static GuideTarget? nearest(
    Game game,
    Player player,
    AssaultTarget target,
    int level,
  ) {
    final map = game.levels[level];
    if (map == null) return null;
    final Set<GridPosition> found = {
      for (final GridPosition p in player.revealedCellsOnLevel(level))
        if (AssaultTarget.at(game, level, p.x, p.y) == target)
          VolcanoFootprint.anchorOf(map, p.x, p.y) ?? p,
    };
    if (found.isEmpty) return null;
    int distance(GridPosition p) {
      final int dx = p.x - player.baseX, dy = p.y - player.baseY;
      return dx * dx + dy * dy;
    }

    final List<GridPosition> sorted =
        found.toList()..sort(
          (a, b) =>
              distance(a) != distance(b)
                  ? distance(a).compareTo(distance(b))
                  : a.y != b.y
                  ? a.y.compareTo(b.y)
                  : a.x.compareTo(b.x),
        );
    return GuideTarget.cell(level, sorted.first);
  }

  /// The post [player] holds on [level], `null` without one.
  static GuideTarget? heldPostOn(Game game, Player player, int level) {
    final held = CapturedBaseFinder.on(game, level, player.id);
    return held == null ? null : GuideTarget.cell(level, held.position);
  }

  /// The cell of [post], `null` when no map holds it.
  static GuideTarget? postCell(Game game, TransitionBase post) {
    for (final int level in game.levels.keys) {
      final GuideTarget? found = _first(
        game,
        level,
        (cell) => identical(cell.transitionBase, post),
      );
      if (found != null) return found;
    }
    return null;
  }

  /// The kernel [player] holds and the button of its garrison, `null`
  /// when they hold none.
  static GuideTarget? heldKernel(Game game, Player player) {
    for (final int level in game.levels.keys) {
      final found = _first(
        game,
        level,
        (cell) =>
            cell.content == CellContentType.volcanicKernel &&
            cell.collectedBy == player.id,
      );
      if (found != null) return GuideTarget.garrison(level, found.cell!);
    }
    return null;
  }

  static GuideTarget? _first(
    Game game,
    int level,
    bool Function(MapCell cell) matches,
  ) {
    final map = game.levels[level];
    if (map == null) return null;
    for (var i = 0; i < map.cells.length; i++) {
      if (matches(map.cells[i])) {
        return GuideTarget.cell(
          level,
          GridPosition(x: i % map.width, y: i ~/ map.width),
        );
      }
    }
    return null;
  }
}
