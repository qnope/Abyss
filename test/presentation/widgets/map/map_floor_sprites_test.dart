import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_floor_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The opacity of [image] at ([x], [y]), from 0 to 255.
  Future<int> alphaAt(WidgetTester tester, ui.Image image, int x, int y) async {
    final bytes = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba));
    return bytes!.getUint8((y * image.width + x) * 4 + 3);
  }

  /// Whether [image] is opaque in its middle and fades out to its edges.
  Future<void> expectSoftDisc(WidgetTester tester, ui.Image image) async {
    final side = image.width, half = side ~/ 2;
    expect(await alphaAt(tester, image, half, half), greaterThan(60));
    for (final (x, y) in [(0, half), (half, 0), (side - 1, half), (0, 0)]) {
      expect(await alphaAt(tester, image, x, y), 0, reason: '($x, $y)');
    }
  }

  testWidgets('a pool of light fades out before its edge, no box showing', (
    tester,
  ) async {
    for (final glow in MapGlow.values.where((g) => g != MapGlow.none)) {
      final pool = await tester.runAsync(() => rasterizePool(glow));
      await expectSoftDisc(tester, pool!);
    }
  });

  testWidgets('a contact shadow is dark under the content, soft around', (
    tester,
  ) async {
    final shadow = await tester.runAsync(rasterizeShadow);
    expect(shadow!.width, floorSpriteSize);
    await expectSoftDisc(tester, shadow);
  });
}
