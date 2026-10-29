import 'dart:ui';

import 'map_cell_visual.dart';
import 'map_content_drawer.dart';
import 'map_flat_contents.dart';
import 'map_projection.dart';
import 'map_standing_order.dart';

/// Depths (x + y) in front of a point from which a sprite may reach up
/// to it: a hit box rises less than three rows of diamonds, the
/// volcano's included.
const _reach = 3;

/// The part of a sprite standing in [area] that a tap picks: the middle
/// 60% of its width and the bottom 80% of its height, leaving out the
/// see-through corners of its square.
Rect standingHitBox(Rect area) => Rect.fromLTRB(
      area.left + 0.2 * area.width,
      area.top + 0.2 * area.height,
      area.right - 0.2 * area.width,
      area.bottom,
    );

/// The cell of the seen content standing over the projection [point], on
/// a map [columns] cells wide drawn from [visuals], or `null` when no
/// sprite stands there.
///
/// A sprite overlaps the cells behind its own, so the content in front
/// wins. Only the cells near [point] are tested.
(int, int)? standingCellAt(
  Offset point, {
  required List<MapCellVisual> visuals,
  required int columns,
}) {
  final rows = columns == 0 ? 0 : visuals.length ~/ columns;
  final flat = MapProjection.toFlat(point);
  // Depth (x + y) and column (x - y) of the cell under the point.
  final depth = ((flat.dx + flat.dy) / cellSize).floor();
  final across = (point.dx / cellSize).round();
  (int, int)? best;
  (int, int)? bestRank;
  for (var s = depth - 2; s <= depth + _reach; s++) {
    for (var d = across - 3; d <= across + 3; d++) {
      if ((s + d).isOdd) continue;
      final x = (s + d) ~/ 2, y = (s - d) ~/ 2;
      if (x < 0 || y < 0 || x >= columns || y >= rows) continue;
      final visual = visuals[y * columns + x];
      if (!visual.revealed || !visual.standsUp) continue;
      final span = visual.contentSpan;
      final area = MapProjection.standingOf((x, y), span: span);
      if (!standingHitBox(area).contains(point)) continue;
      final rank = standingRankOf((x, y), span: span);
      if (bestRank == null || compareStandingRanks(rank, bestRank) > 0) {
        best = (x, y);
        bestRank = rank;
      }
    }
  }
  return best;
}
