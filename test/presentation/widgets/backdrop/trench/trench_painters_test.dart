import 'dart:math' as math;

import 'package:abyss/presentation/theme/abyss_trench_theme.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_ridges_painter.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_water_painter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tile = Size(390, 700);

  /// A draw of [method] filled with a gradient, holding [inside] and not
  /// [outside].
  PaintPatternPredicate shaded(Symbol method,
          {List<Offset> inside = const [], List<Offset> outside = const []}) =>
      (name, args) {
        if (name != method || (args.last as Paint).shader == null) {
          return false;
        }
        bool holds(Offset p) => switch (args.first) {
              final Rect rect => rect.contains(p),
              final Path path => path.contains(p),
              _ => false,
            };
        return inside.every(holds) && !outside.any(holds);
      };

  group('the water', () {
    const painter = TrenchWaterPainter();
    void paint(Canvas canvas) => painter.paint(canvas, tile);

    test('fills the tile and its overscan, then lets rays fall', () {
      final pattern = paints
        ..something(shaded(#drawRect, inside: [
          const Offset(1, -0.5 * 700),
          const Offset(389, 1.5 * 700),
        ]));
      for (var i = 0; i < TrenchWaterPainter.rays; i++) {
        pattern.something(shaded(#drawPath));
      }
      expect(paint, pattern);
      expect(paint,
          paintsExactlyCountTimes(#drawPath, TrenchWaterPainter.rays));
    });

    test('is drawn again only for another seed', () {
      expect(painter.shouldRepaint(const TrenchWaterPainter()), isFalse);
      expect(painter.shouldRepaint(const TrenchWaterPainter(seed: 2)), isTrue);
    });
  });

  group('the ridges', () {
    const painter = TrenchRidgesPainter();
    void paint(Canvas canvas) => painter.paint(canvas, tile);

    test('raise two walls from the bottom of the tile, the far one first',
        () {
      final low = [const Offset(5, 0.9 * 700), const Offset(385, 1.4 * 700)];
      final high = [const Offset(200, 0.05 * 700)];
      expect(
        paint,
        paints
          ..something(shaded(#drawPath, inside: low, outside: high))
          ..something(shaded(#drawPath, inside: low, outside: high)),
      );
    });

    test('light their crests, and a few creatures glow on them', () {
      PaintPatternPredicate tinted(Color colour) => (name, args) =>
          args.isNotEmpty &&
          args.last is Paint &&
          (args.last as Paint).color.toARGB32() == colour.toARGB32();
      expect(
        paint,
        paints
          ..something(tinted(AbyssTrenchTheme.farRim))
          ..something(tinted(AbyssTrenchTheme.midRim)),
      );
      expect(paint, paintsExactlyCountTimes(#drawCircle,
          3 * (TrenchRidgesPainter.farSpecks + TrenchRidgesPainter.midSpecks)));
    });

    test('sink into the dark of the abyss under a veil of water', () {
      expect(
        paint,
        paints
          ..something(shaded(#drawRect,
              inside: [const Offset(10, 0.9 * 700)],
              outside: [const Offset(10, 0.3 * 700)]))
          ..rect(color: AbyssTrenchTheme.veil),
      );
    });

    test('is drawn again only for another seed', () {
      expect(painter.shouldRepaint(const TrenchRidgesPainter()), isFalse);
      expect(painter.shouldRepaint(const TrenchRidgesPainter(seed: 9)), isTrue);
    });
  });

  test('crests join across the edges of a tile, for a seamless wrap', () {
    for (final seed in [1, 2, 3]) {
      final crest = ridgeCrest(math.Random(seed),
          width: 390, height: 700, base: 0.4, amplitude: 0.12, phase: 0);
      expect(crest.first.dx, 0);
      expect(crest.last.dx, 390);
      expect(crest.last.dy, crest.first.dy);
      for (var i = 1; i < crest.length; i++) {
        expect(crest[i].dx, greaterThanOrEqualTo(crest[i - 1].dx));
      }
      for (final p in crest) {
        expect(p.dy, inInclusiveRange(0.4 * 700 - 0.12 * 700 - 0.18 * 700,
            0.4 * 700));
      }
      final again = ridgeCrest(math.Random(seed),
          width: 390, height: 700, base: 0.4, amplitude: 0.12, phase: 0);
      expect(again, crest);
    }
  });
}
