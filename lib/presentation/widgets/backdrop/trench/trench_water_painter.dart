import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../../theme/abyss_trench_theme.dart';

/// The far water of a deep trench, as a [ParallaxLayer] tile: lit from
/// the surface far above, darkening into the abyss, with a few rays of
/// daylight slanting down from the top.
///
/// Covers its tile's height again above and below it (the overscan), and
/// draws each ray again a tile to the left and right, so the tile joins
/// seamlessly to its neighbours. The rays are scattered by [seed].
class TrenchWaterPainter extends CustomPainter {
  /// Rays of light in a tile.
  static const rays = 6;

  final int seed;

  const TrenchWaterPainter({this.seed = 1});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final (w, h) = (size.width, size.height);
    canvas.drawRect(
      Rect.fromLTRB(0, -h, w, 2 * h),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h),
            AbyssTrenchTheme.water, AbyssTrenchTheme.waterStops),
    );
    final random = math.Random(seed);
    final light = Paint()
      ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h),
          AbyssTrenchTheme.ray, AbyssTrenchTheme.rayStops);
    for (var i = 0; i < rays; i++) {
      final x = (-0.1 + 1.1 * random.nextDouble()) * w;
      final width = (0.05 + 0.09 * random.nextDouble()) * w;
      final ray = Path();
      for (final shift in [-w, 0.0, w]) {
        final left = x + shift;
        ray.addPolygon([
          Offset(left, 0),
          Offset(left + width, 0),
          Offset(left + 2.8 * width + 0.2 * w, h),
          Offset(left + 0.2 * w, h),
        ], true);
      }
      canvas.drawPath(ray, light);
    }
  }

  @override
  bool shouldRepaint(TrenchWaterPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
