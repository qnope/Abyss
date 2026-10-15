import 'dart:ui';

import '../../../../theme/abyss_motion.dart';
import '../../map_content_drawer.dart';
import '../../token/map_token_trip.dart';

/// Where an army's token goes as it attacks what stands on [target] (the
/// top left of a place [span] cells across), having set off from
/// [origin]: it swims to the [approach] cell beside the place, lunges
/// part of the way towards its middle, and may retreat a cell.
class StrikeGeometry {
  /// Share of the way to the lair a lunge reaches.
  static const lungeReach = 0.45;

  final (int, int) origin;
  final (int, int) target;
  final int span;

  const StrikeGeometry({
    required this.origin,
    required this.target,
    this.span = 1,
  });

  /// The cell beside the place the token attacks from.
  (int, int) get approach => approachCell(origin, target, span: span);

  /// The cell beside the place [span] cells across from [target], on the
  /// side of [origin] (the origin itself when it touches the place). From
  /// within the place, the cell on its left, or on its right at the left
  /// edge of the map.
  static (int, int) approachCell((int, int) origin, (int, int) target,
      {int span = 1}) {
    final x = _beside(origin.$1, target.$1, span);
    final y = _beside(origin.$2, target.$2, span);
    if (x == null && y == null) {
      return (target.$1 > 0 ? target.$1 - 1 : target.$1 + span, origin.$2);
    }
    return (x ?? origin.$1, y ?? origin.$2);
  }

  /// The row or column beside a place from [start] to [start] + [span]
  /// on the side of [from], or `null` when [from] lies along the place.
  static int? _beside(int from, int start, int span) {
    if (from < start) return start - 1;
    if (from >= start + span) return start + span;
    return null;
  }

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

  /// Where what is attacked is drawn: a lair's monster in the middle of
  /// its cell, or a wide place over all its cells.
  Rect get lairRect {
    final corner = Offset(target.$1 * cellSize, target.$2 * cellSize);
    if (span > 1) return corner & Size.square(span * cellSize);
    return Rect.fromCenter(
      center: corner + const Offset(cellSize / 2, cellSize / 2),
      width: MapContentDrawer.contentSize,
      height: MapContentDrawer.contentSize,
    );
  }

  /// One cell's length from [from], back towards the origin, or straight
  /// away from the place when the token set off beside or within it.
  Offset _away(Offset from) {
    var away = _center(origin) - from;
    if (away.distance < 1 || _within(origin)) away = from - lairRect.center;
    return away / away.distance;
  }

  bool _within((int, int) cell) =>
      cell.$1 >= target.$1 && cell.$1 < target.$1 + span &&
      cell.$2 >= target.$2 && cell.$2 < target.$2 + span;

  static Offset _center((int, int) cell) =>
      Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);
}
