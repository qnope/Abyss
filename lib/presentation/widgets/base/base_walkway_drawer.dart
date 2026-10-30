import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_slot_projection.dart';
import 'base_walkways.dart';

/// Draws the lit metal walkways of the base, in projection coordinates:
/// a plank of [width] cells (the base's, or narrower for the alleys of
/// the army's parade ground) laid on the sand along each leg, its shadow
/// under it, slats across it every half cell, and a lamp on every other
/// slat. Its paints are made once and reused for every leg.
class BaseWalkwayDrawer {
  /// Width of a walkway of the base, in cells.
  static const standardWidth = 0.42;

  /// Length of walkway between two slats, in cells.
  static const slatGap = 0.5;

  /// Width of the walkways it draws, in cells.
  final double width;

  final _shadow = Paint()
    ..color = AbyssIslandColors.walkShadow.withValues(alpha: .45);
  final _rim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = .8 * baseMockPixel
    ..color = AbyssIslandColors.walkRim.withValues(alpha: .45);
  final _slat = Paint()
    ..strokeWidth = .8 * baseMockPixel
    ..color = AbyssIslandColors.slat;

  BaseWalkwayDrawer({this.width = standardWidth});

  /// Draws the walkway along [leg].
  void paint(Canvas canvas, BaseWalkway leg) {
    final (from, to) = leg;
    final along = to - from;
    final length = along.distance;
    final step = along / length;
    final side = Offset(step.dy.abs(), step.dx.abs()) * (width / 2);
    // A half width further at each end, so the corner of an L is closed.
    final start = from - step * (width / 2), end = to + step * (width / 2);
    final plank = polygonOf([
      baseGroundToProjection(start - side),
      baseGroundToProjection(start + side),
      baseGroundToProjection(end + side),
      baseGroundToProjection(end - side),
    ]);
    canvas.drawPath(plank.shift(const Offset(0, 1.5 * baseMockPixel)), _shadow);
    final box = plank.getBounds();
    canvas.drawPath(
      plank,
      Paint()
        ..shader = ui.Gradient.linear(box.topLeft, box.bottomRight, const [
          AbyssIslandColors.walkLight,
          AbyssIslandColors.walkDark,
        ]),
    );
    canvas.drawPath(plank, _rim);
    final slats = (length / slatGap).floor();
    for (var k = 1; k < slats; k++) {
      final at = from + along * (k / slats);
      final edge = baseGroundToProjection(at - side);
      canvas.drawLine(edge, baseGroundToProjection(at + side), _slat);
      if (k.isEven) {
        paintGlow(canvas, edge, 3 * baseMockPixel, AbyssColors.biolumCyan,
            opacity: .7);
      }
    }
  }
}
