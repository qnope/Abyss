import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/ambience/creature_sheet.dart';
import 'package:abyss/presentation/widgets/ambience/creature_undulation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wave = CreatureUndulation.standard;

  /// A plain white square bitmap of [side] pixels.
  Future<ui.Image> square(int side) {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(Rect.fromLTWH(0, 0, side.toDouble(),
        side.toDouble()), Paint()..color = const Color(0xFFFFFFFF));
    return recorder.endRecording().toImage(side, side);
  }

  testWidgets('packs every frame of the loop in one atlas', (tester) async {
    final sheet = await tester.runAsync(() async =>
        CreatureSheet.build(await square(64), undulation: wave));
    final rows = (wave.frames / CreatureSheet.columns).ceil();
    expect(sheet!.atlas.width, CreatureSheet.columns * CreatureSheet.pixels);
    expect(sheet.atlas.height, rows * CreatureSheet.pixels);
    final bytes = await tester.runAsync(sheet.atlas.toByteData);
    int alphaAt(Offset point) {
      final at = point.dy.toInt() * sheet.atlas.width + point.dx.toInt();
      return bytes!.getUint8(at * 4 + 3);
    }

    for (var frame = 0; frame < wave.frames; frame++) {
      final rect = sheet.frameRect(frame);
      expect(alphaAt(rect.center), 255, reason: 'frame $frame');
      expect(alphaAt(rect.topLeft + const Offset(1, 1)), 0);
    }
  });

  testWidgets('building a sheet leaves its bitmap to its owner', (
    tester,
  ) async {
    final bitmap = (await tester.runAsync(() => square(64)))!;
    await tester.runAsync(() => CreatureSheet.build(bitmap, undulation: wave));
    expect(bitmap.debugDisposed, isFalse);
    bitmap.dispose();
  });

  test('frames are read row by row', () {
    final sheet = CreatureSheet(_NoImage(), undulation: wave);
    const px = CreatureSheet.pixels * 1.0;
    expect(sheet.frameRect(0), const Rect.fromLTWH(0, 0, px, px));
    expect(sheet.frameRect(1), const Rect.fromLTWH(px, 0, px, px));
    expect(sheet.frameRect(CreatureSheet.columns),
        const Rect.fromLTWH(0, px, px, px));
  });

  test('a frame spills around the body by the reach of the wave', () {
    final sheet = CreatureSheet(_NoImage(), undulation: wave);
    const body = Rect.fromLTWH(10, 10, 28, 28);
    final dst = sheet.frameDst(body);
    expect(dst.center, within(distance: 1e-9, from: body.center));
    expect(dst.width, closeTo(28 * (1 + 2 * wave.reach), 1e-9));
  });
}

class _NoImage implements ui.Image {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
