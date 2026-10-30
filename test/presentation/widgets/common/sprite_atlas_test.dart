import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/common/sprite_atlas.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [width] by [height] bitmap of [color], its left column red.
Future<ui.Image> _sprite(int width, int height, Color color) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = color)
    ..drawRect(Rect.fromLTWH(0, 0, 1, height.toDouble()),
        Paint()..color = const Color(0xFFFF0000));
  return recorder.endRecording().toImage(width, height);
}

void main() {
  testWidgets('packs each sprite whole, pixel for pixel, apart from the '
      'others by a transparent margin', (tester) async {
    final atlas = (await tester.runAsync(() async => SpriteAtlas.pack({
          'a': await _sprite(40, 20, const Color(0x8000FF00)),
          'b': await _sprite(30, 30, const Color(0xFF0000FF)),
          'c': await _sprite(10, 50, const Color(0xFFFFFFFF)),
        })))!;
    addTearDown(atlas.dispose);
    final bytes = (await tester.runAsync(
        () => atlas.image.toByteData()))!;
    int pixelAt(double x, double y) =>
        bytes.getUint32((y.floor() * atlas.image.width + x.floor()) * 4);
    final pad = SpriteAtlas.padding.toDouble();
    final rects = [for (final key in ['a', 'b', 'c']) atlas.rectOf(key)!];
    expect(rects.map((r) => r.size),
        [const Size(40, 20), const Size(30, 30), const Size(10, 50)]);
    for (final rect in rects) {
      expect(rect.left, greaterThanOrEqualTo(pad));
      expect(rect.top, greaterThanOrEqualTo(pad));
      expect(rect.right + pad, lessThanOrEqualTo(atlas.image.width));
      expect(rect.bottom + pad, lessThanOrEqualTo(atlas.image.height));
      for (final other in rects.where((r) => r != rect)) {
        expect(rect.inflate(pad).overlaps(other.inflate(pad)), isFalse);
      }
      // The left column is red, the rest the sprite's colour, untouched.
      expect(pixelAt(rect.left, rect.center.dy), 0xFF0000FF); // RGBA
      expect(pixelAt(rect.left - 1, rect.center.dy), 0);
      expect(pixelAt(rect.right, rect.center.dy), 0);
      expect(pixelAt(rect.center.dx, rect.top - 1), 0);
      expect(pixelAt(rect.center.dx, rect.bottom), 0);
    }
    expect(pixelAt(rects[0].center.dx, rects[0].center.dy), 0x00800080);
    expect(pixelAt(rects[1].center.dx, rects[1].center.dy), 0x0000FFFF);
    expect(atlas.rectOf('d'), isNull);
  });

  testWidgets('keeps one shader by sampling, disposed with its bitmap',
      (tester) async {
    final atlas = (await tester.runAsync(() async =>
        SpriteAtlas.pack({1: await _sprite(4, 4, const Color(0xFF000000))})))!;
    final smooth = atlas.shaderOf(FilterQuality.medium);
    expect(atlas.shaderOf(FilterQuality.medium), same(smooth));
    final sharp = atlas.shaderOf(FilterQuality.none);
    expect(sharp, isNot(same(smooth)));
    atlas.dispose();
    expect(atlas.image.debugDisposed, isTrue);
    expect(smooth.debugDisposed, isTrue);
    expect(sharp.debugDisposed, isTrue);
  });
}
