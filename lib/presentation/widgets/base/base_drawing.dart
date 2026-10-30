import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_island_colors.dart';
import '../map/map_projection.dart';

/// One pixel of the approved mockup, whose cells are 46 pixels wide, in
/// projection units: the base's drawings keep the mockup's proportions.
const baseMockPixel = MapProjection.tileWidth / 46;

/// Draws of a seeded [Random] within a range.
extension RandomBetween on Random {
  /// A value from [low] to [high].
  double between(double low, double high) =>
      low + (high - low) * nextDouble();
}

/// A paint filling with a vertical gradient over [box]: [colors] at
/// [stops] from its top to its bottom.
Paint verticalGradient(Rect box, List<Color> colors, List<double> stops) =>
    Paint()
      ..shader = ui.Gradient.linear(
          box.topCenter, box.bottomCenter, colors, stops);

/// Draws a soft round glow of [color] around [centre], its bright [core]
/// in the middle, as the lights of the mockup.
void paintGlow(
  Canvas canvas,
  Offset centre,
  double radius,
  Color color, {
  Color core = AbyssIslandColors.lampCore,
  double opacity = 1,
}) {
  canvas.drawCircle(
    centre,
    radius,
    Paint()
      ..shader = ui.Gradient.radial(centre, radius, [
        core.withValues(alpha: 0.95 * opacity),
        color.withValues(alpha: 0.45 * opacity),
        color.withValues(alpha: 0),
      ], const [0, 0.35, 1]),
  );
}

/// A polygon through [points].
Path polygonOf(List<Offset> points) => Path()..addPolygon(points, true);

/// The closed polygon through [points] cut in dashes [dash] long, [gap]
/// apart, the pattern running on from one edge to the next.
Path dashedPolygonOf(List<Offset> points, double dash, double gap) {
  final path = Path();
  var on = true, left = dash;
  for (var k = 0; k < points.length; k++) {
    final from = points[k], to = points[(k + 1) % points.length];
    final length = (to - from).distance;
    var done = 0.0;
    while (done < length) {
      final step = min(left, length - done);
      final a = Offset.lerp(from, to, done / length)!;
      final b = Offset.lerp(from, to, (done + step) / length)!;
      if (on) {
        path
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy);
      }
      done += step;
      left -= step;
      if (left <= 0) {
        on = !on;
        left = on ? dash : gap;
      }
    }
  }
  return path;
}
