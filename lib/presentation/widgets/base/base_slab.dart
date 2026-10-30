import 'dart:math';
import 'dart:ui';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_slot_projection.dart';

const _px = baseMockPixel;

/// Draws, in projection coordinates, the thickness of a plateau of
/// [size] cells: the two rock faces under its front edges, [depth] tall,
/// with their strata, stones, glowing specks and roots over the lip,
/// sinking into the dark below.
void paintBaseSlab(Canvas canvas, int size, double depth, {int seed = 5}) {
  final n = size.toDouble();
  final left = baseGroundToProjection(Offset(0, n));
  final bottom = baseGroundToProjection(Offset(n, n));
  final right = baseGroundToProjection(Offset(n, 0));
  final random = Random(seed);
  _face(canvas, left, bottom, depth, random, lit: true);
  _face(canvas, bottom, right, depth, random, lit: false);
  canvas.drawOval(
    Rect.fromCenter(
      center: bottom.translate(0, depth * 1.1),
      width: (right.dx - left.dx) * 1.1,
      height: depth * 1.4,
    ),
    Paint()
      ..color = AbyssIslandColors.crevice.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18 * _px),
  );
}

void _face(Canvas canvas, Offset a, Offset b, double depth, Random random,
    {required bool lit}) {
  const steps = 22;
  final face = Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy);
  for (var k = steps; k >= 0; k--) {
    final edge = Offset.lerp(a, b, k / steps)!;
    final jag = k == 0 || k == steps ? 0 : random.between(-.15, .35) * depth;
    face.lineTo(edge.dx, edge.dy + depth + jag);
  }
  face.close();
  canvas.drawPath(
    face,
    verticalGradient(
      face.getBounds(),
      lit
          ? const [
              AbyssIslandColors.litRockTop,
              AbyssIslandColors.litRockMid,
              AbyssIslandColors.litRockBottom,
            ]
          : const [
              AbyssIslandColors.shadedRockTop,
              AbyssIslandColors.shadedRockMid,
              AbyssIslandColors.shadedRockBottom,
            ],
      const [0, 0.25, 1],
    ),
  );
  _strata(canvas, a, b, depth, lit);
  for (var k = 0; k < 26; k++) {
    final at = _onFace(a, b, random, depth, .08, .7);
    final r = random.between(1.2, 3.6) * _px;
    final colour = Color.lerp(AbyssIslandColors.stoneLight,
        AbyssIslandColors.stoneDark, random.nextDouble())!;
    canvas.drawOval(Rect.fromCenter(center: at, width: 2 * r, height: 1.4 * r),
        Paint()..color = colour);
  }
  for (var k = 0; k < 9; k++) {
    paintGlow(canvas, _onFace(a, b, random, depth, .2, .8), 3.5 * _px,
        AbyssColors.biolumTeal, core: AbyssIslandColors.glowCore);
  }
  _roots(canvas, a, b, depth, random);
  canvas.drawLine(
    a,
    b,
    Paint()
      ..strokeWidth = 1.4 * _px
      ..color = (lit ? AbyssIslandColors.litLip : AbyssIslandColors.shadedLip)
          .withValues(alpha: 0.55),
  );
}

/// A random point of the face under the edge from [a] to [b], between
/// [low] and [high] of its [depth] below the edge.
Offset _onFace(Offset a, Offset b, Random random, double depth, double low,
        double high) =>
    Offset.lerp(a, b, random.nextDouble())!
        .translate(0, random.between(low, high) * depth);

void _strata(Canvas canvas, Offset a, Offset b, double depth, bool lit) {
  final colour =
      lit ? AbyssIslandColors.litStrata : AbyssIslandColors.shadedStrata;
  for (var k = 1; k < 6; k++) {
    final t = k / 6.5;
    final band = Path()..moveTo(a.dx, a.dy + depth * t);
    for (var s = 1; s <= 30; s++) {
      final p = Offset.lerp(a, b, s / 30)!;
      band.lineTo(p.dx, p.dy + depth * t + sin(s * .9 + k) * depth * .02);
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.2 - t * .6) * _px
      ..color = colour.withValues(alpha: .45 - t * .35);
    canvas.drawPath(band, stroke);
    stroke
      ..strokeWidth = .8 * _px
      ..color = AbyssIslandColors.crevice.withValues(alpha: .4 - t * .25);
    canvas.drawPath(band.shift(const Offset(0, 2.8 * _px)), stroke);
  }
}

void _roots(Canvas canvas, Offset a, Offset b, double depth, Random random) {
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  for (var k = 0; k < 14; k++) {
    final lip = Offset.lerp(a, b, random.between(.02, .98))!;
    final length = random.between(.15, .55) * depth;
    final sway = random.between(-4, 4) * _px;
    const roots = AbyssIslandColors.roots;
    stroke
      ..strokeWidth = random.between(.8, 1.6) * _px
      ..color = roots[random.nextInt(roots.length)].withValues(alpha: .85);
    canvas.drawPath(
      Path()
        ..moveTo(lip.dx, lip.dy)
        ..relativeQuadraticBezierTo(sway, length / 2, sway * .4, length),
      stroke,
    );
  }
}
