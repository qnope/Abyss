import 'dart:math';
import 'dart:ui';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_slot_projection.dart';

const _px = baseMockPixel;
const _steps = 14;

/// Draws, in projection coordinates, the rock pillar a plateau of [size]
/// cells stands on, from under its slab ([depth] tall) down to [bottom],
/// tapering and fading into the dark of the trench: two faces split by
/// a ridge, with ledges, a few glowing specks and hanging algae.
void paintBaseSpire(
  Canvas canvas,
  int size,
  double depth, {
  required double bottom,
  int seed = 8,
}) {
  final n = size.toDouble();
  final tip = baseGroundToProjection(Offset(n, n));
  final random = Random(seed);
  final ridgeTop = tip.dy + depth * .95;
  final ridge = [
    for (var k = 0; k <= _steps; k++)
      Offset(tip.dx + (k > 0 ? random.between(-3, 3) * _px : 0),
          ridgeTop + (bottom - ridgeTop) * k / _steps),
  ];
  final sides = [
    (baseGroundToProjection(Offset(0, n)), -1.0, true),
    (baseGroundToProjection(Offset(n, 0)), 1.0, false),
  ];
  for (final (corner, side, lit) in sides) {
    final contour = _contourOf(corner, tip.dx, depth, bottom, random);
    final face = polygonOf([...contour, ...ridge.reversed]);
    canvas.drawPath(
      face,
      verticalGradient(face.getBounds(), [
        lit ? AbyssIslandColors.litRockTop : AbyssIslandColors.shadedRockTop,
        lit ? AbyssIslandColors.litRockDeep : AbyssIslandColors.shadedRockDeep,
        AbyssColors.abyssBlack.withValues(alpha: 0),
      ], const [0, 0.45, 1]),
    );
    _ledges(canvas, contour, ridge, side, random);
    _algae(canvas, contour, ridge, random);
  }
  canvas.drawPoints(
    PointMode.polygon,
    ridge,
    Paint()
      ..strokeWidth = 1.2 * _px
      ..color = AbyssIslandColors.ledge.withValues(alpha: .35),
  );
}

/// The outer edge of a face, from under [corner] towards the ridge at
/// [ridgeX], down to [bottom].
List<Offset> _contourOf(Offset corner, double ridgeX, double depth,
    double bottom, Random random) {
  final x0 = corner.dx + (ridgeX - corner.dx) * .1;
  final y0 = corner.dy + depth * .9;
  return [
    for (var k = 0; k <= _steps; k++)
      Offset(
        x0 +
            (ridgeX - x0) * pow(k / _steps, .8) * .62 +
            (k > 0 && k < _steps ? random.between(-5, 5) * _px : 0),
        y0 + (bottom - y0) * k / _steps,
      ),
  ];
}

/// The point at [t] across the face, from its edge to the ridge, at [k].
Offset _across(List<Offset> contour, List<Offset> ridge, int k, double t) =>
    Offset.lerp(contour[k], ridge[k], t)!;

void _ledges(Canvas canvas, List<Offset> contour, List<Offset> ridge,
    double side, Random random) {
  final stroke = Paint()..strokeWidth = _px;
  for (var n = 0; n < 26; n++) {
    final k = random.nextInt(_steps - 3);
    final at = _across(contour, ridge, k, random.nextDouble())
        .translate(0, random.between(0, 14) * _px);
    final opacity = .55 * (1 - k / _steps);
    final width = random.between(6, 16) * _px;
    final start = at.translate(-width / 2, 0);
    final run = Offset(width, side * -width * .25);
    stroke.color = AbyssIslandColors.ledge.withValues(alpha: opacity);
    canvas.drawLine(start, start + run, stroke);
    stroke.color = AbyssIslandColors.crevice.withValues(alpha: opacity);
    final under = start.translate(0, 1.5 * _px);
    canvas.drawLine(under, under + run, stroke);
    if (random.nextDouble() < .18) {
      paintGlow(canvas, at.translate(0, 4 * _px), 3.4 * _px,
          AbyssColors.biolumTeal,
          core: AbyssIslandColors.glowCore, opacity: min(1, opacity + .35));
    }
  }
}

void _algae(Canvas canvas, List<Offset> contour, List<Offset> ridge,
    Random random) {
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.2 * _px;
  for (var n = 0; n < 8; n++) {
    final k = random.nextInt(_steps ~/ 2 + 1);
    final at = _across(contour, ridge, k, random.nextDouble())
        .translate(0, random.between(0, 20) * _px);
    final length = random.between(10, 30) * _px;
    stroke.color =
        AbyssIslandColors.roots.first.withValues(alpha: .75 * (1 - k / _steps));
    canvas.drawPath(
      Path()
        ..moveTo(at.dx, at.dy)
        ..relativeQuadraticBezierTo(
            random.between(-4, 4) * _px, length / 2, 0, length),
      stroke,
    );
  }
}
