import 'dart:ui';

/// One block of a coral rampart, in ground coordinates counted in cells:
/// the [ground] it stands on, [height] tall in projection units, and the
/// two ends of its [face], its edge facing the viewer (its larger v for a
/// block running along u, its larger u otherwise).
class BaseRampartSegment {
  /// The four corners of its foot.
  final List<Offset> ground;

  /// The bottom of its face seen from the front, from left to right.
  final (Offset, Offset) face;
  final double height;

  /// Whether it runs along u, its face then lit from the left.
  final bool alongU;

  /// Whether it stands on a front edge, before the buildings.
  final bool front;

  /// Scatters its pores and polyps.
  final int seed;

  const BaseRampartSegment._(this.ground, this.face, this.height,
      this.alongU, this.front, this.seed);

  /// The block from [start] to [end] along the rim, as thick as the
  /// rampart inward from there (toward smaller u or v for a [front] one).
  factory BaseRampartSegment.along({
    required Offset start,
    required Offset end,
    required bool alongU,
    required bool front,
    required double height,
    required int seed,
    required double thickness,
  }) {
    final inward = front ? -thickness : thickness;
    if (alongU) {
      final near = start.dy, far = start.dy + inward;
      final low = near < far ? near : far, high = near < far ? far : near;
      return BaseRampartSegment._([
        Offset(start.dx, low),
        Offset(end.dx, low),
        Offset(end.dx, high),
        Offset(start.dx, high),
      ], (Offset(start.dx, high), Offset(end.dx, high)), height, alongU,
          front, seed);
    }
    final near = start.dx, far = start.dx + inward;
    final low = near < far ? near : far, high = near < far ? far : near;
    return BaseRampartSegment._([
      Offset(low, start.dy),
      Offset(high, start.dy),
      Offset(high, end.dy),
      Offset(low, end.dy),
    ], (Offset(high, start.dy), Offset(high, end.dy)), height, alongU, front,
        seed);
  }

  /// The sort key from the back (low) to the front (high).
  double get depth {
    final (a, b) = face;
    return (a.dx + a.dy + b.dx + b.dy) / 2;
  }

  @override
  String toString() => 'BaseRampartSegment($ground, $height)';
}
