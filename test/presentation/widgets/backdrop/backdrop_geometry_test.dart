import 'dart:ui';

import 'package:abyss/presentation/widgets/backdrop/backdrop_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

const _art = Size(1600, 2200);
const _focus = Offset(800, 1100);

void main() {
  group('coverCrop', () {
    test('keeps the full height of a phone and centres on the focus', () {
      final crop = coverCrop(_art, const Size(390, 844), _focus);
      expect(crop.height, closeTo(2200, 0.01));
      expect(crop.top, closeTo(0, 0.01));
      expect(crop.width / crop.height, closeTo(390 / 844, 1e-6));
      expect(crop.center.dx, closeTo(800, 0.01));
    });

    test('keeps the full width of a wide screen around the focus', () {
      final crop = coverCrop(_art, const Size(1920, 1080), _focus);
      expect(crop.width, closeTo(1600, 0.01));
      expect(crop.left, closeTo(0, 0.01));
      expect(crop.center.dy, closeTo(1100, 0.01));
    });

    test('never crops outside the art', () {
      final crop = coverCrop(_art, const Size(1920, 400), const Offset(0, 0));
      expect(crop.left, 0);
      expect(crop.top, 0);
      final low = coverCrop(_art, const Size(1920, 400), const Offset(0, 2200));
      expect(low.bottom, closeTo(2200, 0.01));
    });

    test('degenerate sizes yield the whole art', () {
      expect(coverCrop(_art, Size.zero, _focus), Offset.zero & _art);
    });
  });

  group('rasterBucket', () {
    test('rounds each side up to the next step', () {
      expect(rasterBucket(const Size(780, 1688)), const Size(1024, 1792));
      expect(rasterBucket(const Size(1, 1)), const Size(256, 256));
    });

    test('nearby sizes share a bucket so resizing seldom rasterizes', () {
      expect(
        rasterBucket(const Size(1000, 1900)),
        rasterBucket(const Size(1010, 1920)),
      );
    });

    test('caps the longest side and keeps the aspect ratio', () {
      final bucket = rasterBucket(const Size(7680, 4320));
      expect(bucket.longestSide, lessThanOrEqualTo(backdropMaxPixels));
      expect(bucket.width / bucket.height, closeTo(16 / 9, 0.2));
    });

    test('an empty box has no bucket', () {
      expect(rasterBucket(Size.zero), Size.zero);
    });
  });
}
