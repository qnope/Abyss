import 'dart:math' as math;
import 'dart:ui';

/// How far a blow that landed [since] ago shakes the map: side to side,
/// up to [amplitude] logical pixels, dying out over [length]; nothing
/// before the blow (`null`) or once it is over.
Offset mapJolt(Duration? since,
    {required Duration length, required double amplitude}) {
  if (since == null || since.isNegative || since >= length) {
    return Offset.zero;
  }
  final p = since.inMicroseconds / length.inMicroseconds;
  return Offset(math.sin(p * 6 * math.pi) * amplitude * (1 - p), 0);
}
