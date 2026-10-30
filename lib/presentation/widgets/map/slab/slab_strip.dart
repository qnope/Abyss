import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'slab_face.dart';

/// A rock face of a slab seen straight on: the strip whose x runs along
/// its lip, from its start, and whose y goes straight down from the lip.
///
/// Its rock drawn in the strip (through [inverse]) is an upright picture
/// that [matrix] lays back slanted on the face: a bitmap of a stretch of
/// it is one image drawn on the map.
class SlabStrip {
  final SlabFace face;

  /// Height the lip climbs (or falls, below 0) per pixel along it.
  final double slope;

  /// The box of the strip the face's rock draws in: past both its ends
  /// (for the algae and stones there) and down to its lowest specks.
  final Rect area;

  SlabStrip(this.face)
      : slope = (face.end.dy - face.start.dy) / (face.end.dx - face.start.dx),
        area = Rect.fromLTRB(-6 * face.unit, -2 * face.unit,
            face.end.dx - face.start.dx + 6 * face.unit,
            0.8 * face.depth + 4 * face.unit);

  /// Length of the lip, along the strip's x.
  double get length => face.end.dx - face.start.dx;

  /// The point of the map at [point] of the strip.
  Offset toFace(Offset point) =>
      face.start + Offset(point.dx, point.dy + slope * point.dx);

  /// The transform from the strip to the map, column-major.
  Float64List get matrix => Float64List.fromList([
        1, slope, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        face.start.dx, face.start.dy, 0, 1,
      ]);

  /// The transform from the map to the strip, column-major.
  Float64List get inverse => Float64List.fromList([
        1, -slope, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        -face.start.dx, slope * face.start.dx - face.start.dy, 0, 1,
      ]);

  /// The box of the map the strip's [area] from [from] to [to] along
  /// the lip covers.
  Rect boundsOf(double from, double to) {
    final ends = [from, to];
    final ys = [
      for (final x in ends) ...[
        face.start.dy + slope * x + area.top,
        face.start.dy + slope * x + area.bottom,
      ],
    ];
    return Rect.fromLTRB(face.start.dx + from, ys.reduce(math.min),
        face.start.dx + to, ys.reduce(math.max));
  }

  /// The stretch of the strip's [area] (from, to, along the lip) that
  /// [visible], a box of the map, sees; none if it sees none.
  (double, double)? spanOn(Rect visible) {
    var from = math.max(area.left, visible.left - face.start.dx);
    var to = math.min(area.right, visible.right - face.start.dx);
    // Where the column under the lip at x overlaps the box's rows.
    final low = visible.top - face.start.dy - area.bottom;
    final high = visible.bottom - face.start.dy - area.top;
    if (slope == 0) {
      if (low > 0 || high < 0) return null;
    } else {
      final (a, b) = (low / slope, high / slope);
      from = math.max(from, math.min(a, b));
      to = math.min(to, math.max(a, b));
    }
    return from < to ? (from, to) : null;
  }
}
