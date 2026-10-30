import 'dart:async';

import 'package:abyss/presentation/widgets/common/painted_raster.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const area = Rect.fromLTWH(0, 0, 40, 20);
  late PaintedRaster raster;
  late StreamController<void> ready;
  late int draws;

  setUp(() {
    ready = StreamController<void>.broadcast();
    raster = PaintedRaster(onReady: () => ready.add(null));
    draws = 0;
  });
  tearDown(() {
    raster.dispose();
    ready.close();
  });

  void red(Canvas canvas) {
    draws++;
    canvas.drawRect(area, Paint()..color = const Color(0xFFFF0000));
  }

  test('rasterizes in the background, after the frame asking: its drawing '
      'meanwhile, then the bitmap, with a call back', () async {
    final next = ready.stream.first;
    expect(raster.prepare('a', area, 2, red), isNull);
    expect(raster.image, isNull);
    expect(
      (Canvas canvas) => raster.drawOn(canvas, offset: const Offset(3, 4)),
      paints
        ..save()
        ..translate(x: 3, y: 4)
        ..scale(x: 0.5, y: 0.5)
        ..clipRect(rect: const Rect.fromLTWH(0, 0, 80, 40))
        ..something((method, _) => method == #drawPicture)
        ..restore(),
    );
    // Asked again while under way, it is not rasterized twice.
    expect(raster.prepare('a', area, 2, red), isNull);
    await next;
    final image = raster.image!;
    expect((image.width, image.height), (80, 40));
    expect(raster.prepare('a', area, 2, red), same(image));
    expect(draws, 1);
  });

  test('keeps only the last bitmap asked, the others dropped as they '
      'come', () async {
    final next = ready.stream.first;
    raster.prepare('a', area, 2, red);
    raster.prepare('b', area, 1, red);
    await next;
    expect(raster.image!.width, 40);
    expect(raster.prepare('b', area, 1, red), same(raster.image));
    // A new one asked: the one kept goes at once, the new one shows next.
    final kept = raster.image!;
    final again = ready.stream.first;
    expect(raster.prepare('c', area, 1, red), isNull);
    expect(kept.debugDisposed, isTrue);
    await again;
    expect(raster.prepare('c', area, 1, red), isNotNull);
  });

  test('disposed while under way, drops the bitmap when it comes, without '
      'calling back', () async {
    var called = false;
    final quiet = PaintedRaster(onReady: () => called = true);
    expect(quiet.prepare('a', area, 2, red), isNull);
    quiet.dispose();
    expect((Canvas canvas) => quiet.drawOn(canvas), paintsNothing);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(called, isFalse);
    expect(quiet.image, isNull);
  });
}
