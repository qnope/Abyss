import 'package:abyss/presentation/widgets/common/painted_raster.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const area = Rect.fromLTWH(-40, 10, 100, 50);
  late PaintedRaster raster;
  late int draws;

  setUp(() {
    raster = PaintedRaster();
    draws = 0;
  });
  tearDown(() => raster.dispose());

  void red(Canvas canvas) {
    draws++;
    canvas.drawRect(area.deflate(10), Paint()..color = const Color(0xFFFF0000));
  }

  test('rasterizes once while its key holds', () {
    final first = raster.prepare('a', area, 2, red);
    expect(raster.prepare('a', area, 2, red), same(first));
    expect(draws, 1);
    expect((first!.width, first.height), (200, 100));
  });

  test('rasterizes again when its key, area or resolution changes, '
      'disposing the bitmap it kept', () {
    var kept = raster.prepare('a', area, 2, red)!;
    for (final (key, at, resolution) in [
      ('b', area, 2.0),
      ('b', area.shift(const Offset(1, 0)), 2.0),
      ('b', area.shift(const Offset(1, 0)), 1.0),
    ]) {
      final image = raster.prepare(key, at, resolution, red)!;
      expect(image, isNot(same(kept)));
      expect(kept.debugDisposed, isTrue);
      kept = image;
    }
    expect(draws, 4);
  });

  test('keeps every side within the largest texture', () {
    final image = raster.prepare(
        'wide', const Rect.fromLTWH(0, 0, 10000, 100), 1, red)!;
    expect(image.width, PaintedRaster.maxSide);
    expect(image.height, closeTo(100 * PaintedRaster.maxSide / 10000, 1));
  });

  test('holds nothing for an empty area, nor once disposed', () {
    expect(raster.prepare('a', Rect.zero, 2, red), isNull);
    expect(draws, 0);
    final image = raster.prepare('a', area, 2, red)!;
    raster.dispose();
    expect(image.debugDisposed, isTrue);
    expect(raster.image, isNull);
  });

  test('draws its bitmap where the drawing lay, shifted', () {
    final image = raster.prepare('a', area, 2, red)!;
    expect(
      (Canvas canvas) => raster.drawOn(canvas, offset: const Offset(5, 6)),
      paints
        ..drawImageRect(
          image: image,
          source: const Rect.fromLTWH(0, 0, 200, 100),
          destination: area.shift(const Offset(5, 6)),
        ),
    );
  });

  test('samples its bitmap smoothly, with mipmaps if asked', () {
    raster.prepare('a', area, 2, red);
    PaintPattern sampled(FilterQuality quality) => paints
      ..something((method, args) =>
          method == #drawImageRect &&
          (args[3] as Paint).filterQuality == quality);
    expect((Canvas canvas) => raster.drawOn(canvas),
        sampled(FilterQuality.low));
    expect(
      (Canvas canvas) =>
          raster.drawOn(canvas, filterQuality: FilterQuality.medium),
      sampled(FilterQuality.medium),
    );
  });

  testWidgets('the bitmap shows the drawing at its place', (tester) async {
    final image = raster.prepare('a', area, 2, red)!;
    final bytes = (await tester.runAsync(() => image.toByteData()))!;
    int alphaAt(Offset point) {
      final x = ((point.dx - area.left) * 2).floor();
      final y = ((point.dy - area.top) * 2).floor();
      return bytes.getUint8((y * image.width + x) * 4 + 3);
    }

    expect(alphaAt(area.center), 255);
    expect(alphaAt(area.topLeft.translate(2, 2)), 0);
    expect(bytes.getUint8((40 * image.width + 100) * 4), 255, reason: 'red');
  });

  test('a drawing with nothing to keep draws nothing', () {
    expect((Canvas canvas) => raster.drawOn(canvas), paintsNothing);
  });
}
