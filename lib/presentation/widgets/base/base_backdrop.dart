import 'dart:math';
import 'dart:ui';

import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';

/// Draws the deep water behind the island over a view of [size]: light
/// falling from above in rays, the far walls of the trench with their
/// pinnacles, and the dark of the abyss rising from below.
void paintBaseBackdrop(Canvas canvas, Size size, {int seed = 7}) {
  final view = Offset.zero & size;
  final w = size.width, h = size.height;
  final random = Random(seed);
  canvas.drawRect(
    view,
    verticalGradient(view, const [
      AbyssIslandColors.waterTop,
      AbyssIslandColors.waterMid,
      AbyssIslandColors.waterBottom,
    ], const [0, 0.35, 1]),
  );
  final ray = verticalGradient(view, [
    AbyssIslandColors.ray.withValues(alpha: .16),
    AbyssIslandColors.rayFade.withValues(alpha: .05),
    AbyssIslandColors.rayFade.withValues(alpha: 0),
  ], const [0, 0.6, 1]);
  for (var k = 0; k < 6; k++) {
    final x = random.between(-.1, 1) * w, width = random.between(.05, .14) * w;
    canvas.drawPath(
      polygonOf([
        Offset(x, 0),
        Offset(x + width, 0),
        Offset(x + width * 2.8 + w * .2, h),
        Offset(x + w * .2, h),
      ]),
      ray,
    );
  }
  _ridge(canvas, size, random, layer: 0, base: .4, rise: .12);
  _ridge(canvas, size, random, layer: 1, base: .52, rise: .16);
  final fall = Rect.fromLTRB(0, h * .55, w, h);
  canvas.drawRect(
    fall,
    verticalGradient(fall, [
      AbyssIslandColors.abyssFall.withValues(alpha: 0),
      AbyssIslandColors.abyssFall.withValues(alpha: .9),
    ], const [0, 1]),
  );
  canvas.drawRect(
      view, Paint()..color = AbyssIslandColors.haze.withValues(alpha: .25));
}

/// A wall of the trench, far ([layer] 0) or nearer (1), its crest around
/// [base] of the height and rising up to [rise] more.
void _ridge(Canvas canvas, Size size, Random random,
    {required int layer, required double base, required double rise}) {
  final w = size.width, h = size.height;
  final crest = <Offset>[];
  var x = -30.0;
  while (x < w + 40) {
    final swell = (sin(x * .013 + layer * 2.1)).abs() * random.between(.6, 1);
    final y = base * h - rise * h * (.35 + .65 * swell);
    if (random.nextDouble() < .22) {
      final pw = random.between(8, 16), ph = random.between(.08, .18) * h;
      crest.addAll([
        Offset(x, y),
        Offset(x + pw * .3, y - ph * .7),
        Offset(x + pw * .45, y - ph),
        Offset(x + pw * .62, y - ph * .78),
        Offset(x + pw, y),
      ]);
      x += pw;
    } else {
      crest.add(Offset(x, y));
      x += random.between(10, 24);
    }
  }
  final wall = polygonOf([Offset(-30, h), ...crest, Offset(w + 40, h)]);
  final box = wall.getBounds();
  final fill = layer == 0
      ? verticalGradient(box, [
          AbyssIslandColors.farRidgeTop.withValues(alpha: .85),
          AbyssIslandColors.farRidgeBottom.withValues(alpha: .85),
        ], const [0, 1])
      : verticalGradient(box, const [
          AbyssIslandColors.midRidgeLit,
          AbyssIslandColors.midRidge,
          AbyssIslandColors.midRidgeDark,
        ], const [0, 0.4, 1]);
  canvas.drawPath(wall, fill);
  canvas.drawPoints(
    PointMode.polygon,
    crest,
    Paint()
      ..strokeWidth = 1
      ..color =
          AbyssIslandColors.ridgeRim.withValues(alpha: layer == 0 ? .15 : .25),
  );
  final speck = Paint();
  for (var k = 0; k < (layer == 0 ? 4 : 10); k++) {
    final at = crest[random.nextInt(crest.length)];
    speck.color =
        AbyssIslandColors.speck.withValues(alpha: random.between(.25, .65));
    canvas.drawCircle(
        at.translate(random.between(-6, 6), random.between(6, 40)),
        random.between(.7, 1.5),
        speck);
  }
}
