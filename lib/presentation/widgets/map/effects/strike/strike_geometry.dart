import 'dart:ui';

import '../../../../theme/abyss_motion.dart';
import '../../map_content_drawer.dart';
import '../../token/map_token_trip.dart';

/// Where an army's token goes as it attacks the lair on [target], having
/// set off from [origin]: it swims to the [approach] cell beside the
/// lair, lunges part of the way towards it, and may retreat a cell.
class StrikeGeometry {
  /// Share of the way to the lair a lunge reaches.
  static const lungeReach = 0.45;

  final (int, int) origin;
  final (int, int) target;

  const StrikeGeometry({required this.origin, required this.target});

  /// The cell beside the lair the token attacks from.
  (int, int) get approach => approachCell(origin, target);

  /// The neighbour of [target] on the side of [origin] (the origin itself
  /// when it touches the target). When they meet, the neighbour on the
  /// left, or on the right at the left edge of the map.
  static (int, int) approachCell((int, int) origin, (int, int) target) {
    final dx = (origin.$1 - target.$1).sign, dy = (origin.$2 - target.$2).sign;
    if (dx == 0 && dy == 0) {
      return (target.$1 > 0 ? target.$1 - 1 : target.$1 + 1, target.$2);
    }
    return (target.$1 + dx, target.$2 + dy);
  }

  /// The token after [swim] of its swim (0 to 1), lunging [reach] of its
  /// way to the lair and having retreated [retreat] of a cell.
  Rect tokenRect({required double swim, double reach = 0, double retreat = 0}) {
    final start = MapTokenTrip.swimmingRect(origin);
    final rest = MapTokenTrip.swimmingRect(approach);
    final swum = Rect.lerp(start, rest, AbyssMotion.travel.transform(swim))!;
    final toward = _center(target) - rest.center;
    final shift = toward * (lungeReach * reach) +
        _away(rest.center) * (AbyssMotion.travel.transform(retreat) * cellSize);
    return swum.shift(shift);
  }

  /// Where the lair's monster is drawn.
  Rect get lairRect => Rect.fromCenter(
        center: _center(target),
        width: MapContentDrawer.contentSize,
        height: MapContentDrawer.contentSize,
      );

  /// One cell's length from [from], back towards the origin, or straight
  /// away from the lair when the token set off beside it.
  Offset _away(Offset from) {
    var away = _center(origin) - from;
    if (away.distance < 1) away = from - _center(target);
    return away / away.distance;
  }

  static Offset _center((int, int) cell) =>
      Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);
}
