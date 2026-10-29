import 'dart:ui';

import '../../../../theme/abyss_motion.dart';
import '../../map_cell_size.dart';
import '../../token/map_token_trip.dart';
import '../map_effect.dart';

/// Where an army's token goes on the flat map as it attacks what stands
/// on [target] (the top left of a place [span] cells across), having set
/// off from [origin]: it swims to the [approach] cell beside the place,
/// lunges part of the way towards its middle, and may retreat a cell.
class StrikeGeometry {
  /// Share of the way to the lair a lunge reaches.
  static const lungeReach = 0.45;

  final (int, int) origin;
  final (int, int) target;
  final int span;

  /// Size of the map in cells, or `null` when unknown: any cell right of
  /// or below the place is then taken as inside it.
  final int? columns, rows;

  const StrikeGeometry({
    required this.origin,
    required this.target,
    this.span = 1,
    this.columns,
    this.rows,
  });

  /// The attack on [target] played on [stage], from the cell its army
  /// set off from.
  StrikeGeometry.staged(MapStage stage, (int, int) target, {int span = 1})
      : this(
          origin: stage.originOf(target),
          target: target,
          span: span,
          columns: stage.columns,
          rows: stage.rows,
        );

  /// The cell beside the place the token attacks from.
  (int, int) get approach => approachCell(origin, target,
      span: span, columns: columns, rows: rows);

  /// The cell beside the place [span] cells across from [target], inside
  /// a map of [columns] by [rows], the token attacks from.
  ///
  /// On screen it lies left or right of the place or in front of it (as
  /// deep as the place's middle or nearer), never behind, where the
  /// token would hide the place. Of those, the one nearest [origin] (the
  /// origin itself when it touches the place there), a side before the
  /// front, the left before the right; from within the place, the first
  /// of them. Only where none lies inside the map (at its bottom corner)
  /// does the token come from behind, and never from the back corner.
  static (int, int) approachCell((int, int) origin, (int, int) target,
      {int span = 1, int? columns, int? rows}) {
    final (tx, ty) = target;
    final within = _covers(target, span, origin);
    (int, int)? best;
    var bestRank = (0, 0, 0, 0);
    for (var x = tx - 1; x <= tx + span; x++) {
      for (var y = ty - 1; y <= ty + span; y++) {
        final outside = x < 0 || y < 0 ||
            (columns != null && x >= columns) || (rows != null && y >= rows);
        if (outside || _covers(target, span, (x, y))) continue;
        final dx = x - origin.$1, dy = y - origin.$2;
        final rank = (_tierOf((x, y), target, span),
            within ? 0 : dx * dx + dy * dy, x + y, x - y);
        if (best == null || _before(rank, bestRank)) {
          (best, bestRank) = ((x, y), rank);
        }
      }
    }
    return best ?? origin;
  }

  /// 0 for a cell left or right of the place on screen or in front of
  /// it, 2 for its back corner, 1 for the cells behind it in between.
  static int _tierOf((int, int) cell, (int, int) target, int span) {
    final (x, y) = cell;
    final (tx, ty) = target;
    if (x + y >= tx + ty + span - 1) return 0;
    return x == tx - 1 && y == ty - 1 ? 2 : 1;
  }

  /// Whether rank [a] comes before [b], field by field.
  static bool _before((int, int, int, int) a, (int, int, int, int) b) {
    if (a.$1 != b.$1) return a.$1 < b.$1;
    if (a.$2 != b.$2) return a.$2 < b.$2;
    if (a.$3 != b.$3) return a.$3 < b.$3;
    return a.$4 < b.$4;
  }

  /// Whether [cell] lies in the place [span] cells across from [target].
  static bool _covers((int, int) target, int span, (int, int) cell) =>
      cell.$1 >= target.$1 && cell.$1 < target.$1 + span &&
      cell.$2 >= target.$2 && cell.$2 < target.$2 + span;

  /// The token after [swim] of its swim (0 to 1), lunging [reach] of its
  /// way to the place and having retreated [retreat] of a cell.
  Rect tokenRect({required double swim, double reach = 0, double retreat = 0}) {
    final start = MapTokenTrip.swimmingRect(origin);
    final rest = MapTokenTrip.swimmingRect(approach);
    final swum = Rect.lerp(start, rest, AbyssMotion.travel.transform(swim))!;
    final toward = lairRect.center - rest.center;
    final shift = toward * (lungeReach * reach) +
        _away(rest.center) * (AbyssMotion.travel.transform(retreat) * cellSize);
    return swum.shift(shift);
  }

  /// The cells what is attacked covers on the flat map: the token lunges
  /// at their middle. The target itself is drawn where it stands.
  Rect get lairRect => Offset(target.$1 * cellSize, target.$2 * cellSize) &
      Size.square(span * cellSize);

  /// One cell's length from [from], back towards the origin, or straight
  /// away from the place when the token set off beside or within it.
  Offset _away(Offset from) {
    var away = _center(origin) - from;
    if (away.distance < 1 || _covers(target, span, origin)) {
      away = from - lairRect.center;
    }
    return away / away.distance;
  }

  static Offset _center((int, int) cell) =>
      Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);
}
