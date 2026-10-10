import '../../action/collect_treasure_action.dart';
import '../../action/explore_action.dart';
import '../../map/cell_content_type.dart';
import '../../map/cell_mask.dart';
import '../../map/game_map.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../map/reveal_area_calculator.dart';
import '../../tech/tech_effects.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';

/// Scouting moves: picking what to explore and picking up what was found.
///
/// Scripts only act on what the player has revealed, like a real player.
extension ExploreMoves on ScriptTurn {
  /// Revealed cells of [level] whose content passes [test].
  List<GridPosition> revealedWhere(int level, bool Function(MapCell) test) {
    final GameMap? map = game.levels[level];
    if (map == null) return const <GridPosition>[];
    return <GridPosition>[
      for (final GridPosition p in player.revealedCellsOnLevel(level))
        if (test(map.cellAt(p.x, p.y))) p,
    ];
  }

  /// Picks up every revealed treasure (resources and ruins) of [level].
  void collectRevealed(int level) {
    final List<GridPosition> treasures = revealedWhere(
      level,
      (MapCell c) =>
          !c.isCollected &&
          (c.content == CellContentType.resourceBonus ||
              c.content == CellContentType.ruins),
    );
    for (final GridPosition p in treasures) {
      tryPerform(CollectTreasureAction(
          targetX: p.x, targetY: p.y, level: level, random: random));
    }
  }

  /// Sends up to [count] scouts of [level] to the frontier cells that
  /// reveal the most new cells, plus [bias] of each target.
  void explore(int level, int count, double Function(GridPosition) bias) {
    final GameMap? map = game.levels[level];
    if (map == null) return;
    final List<GridPosition> revealed = player.revealedCellsOnLevel(level);
    final Set<GridPosition> known = <GridPosition>{...revealed};
    final int side = TechEffects.of(player).revealSide;
    // Orders only queue explorations: the frontier holds for every scout.
    final List<GridPosition> frontier = _frontier(map, revealed);
    for (int i = 0; i < count; i++) {
      if ((player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0) <= 0) {
        return;
      }
      GridPosition? best;
      double bestScore = 0;
      for (final GridPosition p in frontier) {
        if (known.contains(p)) continue;
        final List<GridPosition> area = _area(map, p, side);
        final int fresh = area.where((a) => !known.contains(a)).length;
        if (fresh == 0) continue;
        final double score = fresh + bias(p);
        if (best == null || score > bestScore) {
          best = p;
          bestScore = score;
        }
      }
      if (best == null) return;
      final ExploreAction action =
          ExploreAction(targetX: best.x, targetY: best.y, level: level);
      if (!tryPerform(action)) return;
      known.addAll(_area(map, best, side));
    }
  }

  /// Whether every cell of [level] has been revealed.
  bool fullyExplored(int level) {
    final GameMap? map = game.levels[level];
    if (map == null) return false;
    return player.revealedCellsOnLevel(level).length >=
        map.width * map.height;
  }

  static List<GridPosition> _area(GameMap map, GridPosition p, int side) =>
      RevealAreaCalculator.cellsToReveal(
        targetX: p.x,
        targetY: p.y,
        side: side,
        mapWidth: map.width,
        mapHeight: map.height,
      );

  /// Unrevealed cells of [map] touching a revealed one, in row-major order.
  static List<GridPosition> _frontier(
    GameMap map,
    Iterable<GridPosition> revealed,
  ) {
    final CellMask mask = CellMask(map.width, map.height, revealed);
    return <GridPosition>[
      for (int y = 0; y < map.height; y++)
        for (int x = 0; x < map.width; x++)
          if (!mask.contains(x, y) && mask.touches(x, y))
            GridPosition(x: x, y: y),
    ];
  }
}
