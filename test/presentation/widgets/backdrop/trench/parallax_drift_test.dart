import 'package:abyss/presentation/widgets/backdrop/trench/parallax_drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const viewport = Size(400, 800);
  const content = Size(2000, 1000);

  group('contentDrift', () {
    test('is nothing while the content is centred, whatever the zoom', () {
      for (final scale in [0.2, 1.0, 3.0]) {
        final centred = Matrix4.translationValues(
            200 - 1000 * scale, 400 - 500 * scale, 0)
          ..scaleByDouble(scale, scale, 1, 1);
        expect(contentDrift(centred, content, viewport), Offset.zero);
      }
    });

    test('follows the content as it pans', () {
      final at = Matrix4.translationValues(-300, -100, 0)
        ..scaleByDouble(0.5, 0.5, 1, 1);
      final panned = Matrix4.translationValues(-260, -130, 0)
        ..scaleByDouble(0.5, 0.5, 1, 1);
      expect(contentDrift(panned, content, viewport) -
          contentDrift(at, content, viewport), const Offset(40, -30));
    });
  });

  group('parallaxShift', () {
    const period = 400.0, overscan = 100.0;
    Offset shift(Offset drift, {double rate = 0.5}) => parallaxShift(drift,
        rate: rate, period: period, overscan: overscan);

    test('moves at its rate of the drift', () {
      expect(shift(const Offset(40, -30)) - shift(Offset.zero),
          const Offset(20, -15));
      expect(shift(const Offset(40, 0), rate: 0.15).dx - shift(Offset.zero).dx,
          closeTo(6, 1e-9));
    });

    test('wraps sideways within a period, so two tiles cover the screen',
        () {
      for (final dx in [-5000.0, -401.0, -1.0, 0.0, 1.0, 399.0, 12345.0]) {
        final x = shift(Offset(dx, 0)).dx;
        expect(x, inInclusiveRange(-period, 0), reason: '$dx');
      }
      expect(shift(const Offset(2 * period, 0)).dx, shift(Offset.zero).dx);
    });

    test('stops sliding up or down past its overscan', () {
      expect(shift(const Offset(0, 5000)).dy, overscan);
      expect(shift(const Offset(0, -5000)).dy, -overscan);
      expect(shift(const Offset(0, 100)).dy, 50);
    });
  });
}
