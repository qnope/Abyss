import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../../theme/abyss_trench_theme.dart';
import 'trench_ridge_crest.dart';

export 'trench_ridge_crest.dart';

/// The walls of a deep trench, as a [ParallaxLayer] tile: a far ridge
/// then a nearer one rising from below, pinnacles on their crests, their
/// edges catching a faint light and a few creatures glowing on them; the
/// abyss darkening below, all under a veil of water.
///
/// Covers its tile's height again below it, and draws everything again a
/// tile to the left and right on crests that join across the tile's
/// edges, so the tile joins seamlessly to its neighbours. Scattered by
/// [seed].
class TrenchRidgesPainter extends CustomPainter {
  /// Creatures glowing on the far ridge and on the near one.
  static const farSpecks = 4;
  static const midSpecks = 10;

  final int seed;

  const TrenchRidgesPainter({this.seed = 1});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final (w, h) = (size.width, size.height);
    final random = math.Random(seed);
    for (final (layer, colours, base, amplitude, rim, specks) in [
      (0, AbyssTrenchTheme.farRidge, 0.4, 0.12, AbyssTrenchTheme.farRim,
          farSpecks),
      (1, AbyssTrenchTheme.midRidge, 0.52, 0.16, AbyssTrenchTheme.midRim,
          midSpecks),
    ]) {
      final crest = ridgeCrest(random, width: w, height: h, base: base,
          amplitude: amplitude, phase: layer * 2.1);
      final top = crest.map((p) => p.dy).reduce(math.min);
      final wall = Path()..moveTo(-w, 2 * h);
      final edge = Path()..moveTo(crest.first.dx - w, crest.first.dy);
      for (final shift in [-w, 0.0, w]) {
        for (final p in crest) {
          wall.lineTo(p.dx + shift, p.dy);
          edge.lineTo(p.dx + shift, p.dy);
        }
      }
      canvas
        ..drawPath(wall..lineTo(2 * w, 2 * h)..close(), Paint()
          ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, h), colours,
              colours.length == 3 ? const [0, 0.4, 1] : null))
        ..drawPath(edge, Paint()
          ..style = PaintingStyle.stroke
          ..color = rim);
      for (var i = 0; i < specks; i++) {
        final p = crest[random.nextInt(crest.length)];
        final at = p.translate(
            -6 + 12 * random.nextDouble(), 6 + 34 * random.nextDouble());
        final radius = 0.7 + 0.8 * random.nextDouble();
        final glow = Paint()
          ..color = AbyssTrenchTheme.speck
              .withValues(alpha: 0.25 + 0.4 * random.nextDouble());
        for (final shift in [-w, 0.0, w]) {
          canvas.drawCircle(at.translate(shift, 0), radius, glow);
        }
      }
    }
    canvas
      ..drawRect(Rect.fromLTRB(0, 0.55 * h, w, 2 * h), Paint()
        ..shader = ui.Gradient.linear(
            Offset(0, 0.55 * h), Offset(0, h), AbyssTrenchTheme.fall))
      ..drawRect(Rect.fromLTRB(0, -h, w, 2 * h),
          Paint()..color = AbyssTrenchTheme.veil);
  }

  @override
  bool shouldRepaint(TrenchRidgesPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
