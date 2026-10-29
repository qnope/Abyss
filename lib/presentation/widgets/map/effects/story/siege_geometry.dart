import 'dart:math' as math;
import 'dart:ui';

import '../../../../theme/abyss_motion.dart';
import '../../map_cell_size.dart';
import '../../token/map_token_trip.dart';

/// Where the attackers of a place go: the place covers [span] cells
/// across from [place], its top left cell; [attackers] tokens close in
/// on it from around, then are pushed back or break in.
class SiegeGeometry {
  /// Number of attackers drawn.
  static const attackers = 3;

  /// How far the attackers set off, in cells beyond the place's edge.
  static const start = 2.5;

  /// How far they stop from the place's edge, in cells.
  static const halt = 0.35;

  /// Share of the way from where they halted to the place's edge a
  /// lunge reaches.
  static const lungeReach = 0.8;

  /// How far they are pushed back, in cells beyond where they halted.
  static const push = 1.5;

  final (int, int) place;
  final int span;

  const SiegeGeometry({required this.place, this.span = 1});

  /// The middle of the place.
  Offset get center => Offset(
      (place.$1 + span / 2) * cellSize, (place.$2 + span / 2) * cellSize);

  /// The radius of the circle through the corners of the place, which
  /// the projection lays on the floor through the vertices of its
  /// diamonds: rings drawn from it surround the content standing there.
  double get radius => span * cellSize * math.sqrt1_2;

  /// Attacker [index] after [approach] of its way in (0 to 1), lunging
  /// [reach] of the way at the place, pushed back [pushed] of the way, or
  /// [breach] of its way into the place.
  Rect attackerRect(int index,
      {required double approach,
      double reach = 0,
      double pushed = 0,
      double breach = 0}) {
    final angle = -math.pi / 2 + index * 2 * math.pi / attackers + 0.4;
    final direction = Offset(math.cos(angle), math.sin(angle));
    final halted = radius + halt * cellSize;
    final far = radius + start * cellSize;
    var distance = far + (halted - far) * AbyssMotion.travel.transform(approach);
    distance -= halt * cellSize * lungeReach * reach;
    distance += push * cellSize * AbyssMotion.enter.transform(pushed);
    distance -= halted * AbyssMotion.exit.transform(breach);
    final side = cellSize * MapTokenTrip.swimScale;
    return Rect.fromCenter(
        center: center + direction * distance, width: side, height: side);
  }
}
