import 'package:abyss/presentation/theme/abyss_trench_theme.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/depth_haze.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/parallax_layer.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_backdrop.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/background_rasters.dart';

void main() {
  testWidgets('the trench lays its water far behind, its ridges nearer', (
    tester,
  ) async {
    final transform = TransformationController();
    addTearDown(transform.dispose);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: TrenchBackdrop(
          transform: transform, content: const Size(2000, 1000)),
    ));
    final layers = tester
        .widgetList<ParallaxLayer>(find.byType(ParallaxLayer))
        .toList();
    expect([for (final l in layers) l.rate],
        [TrenchBackdrop.farRate, TrenchBackdrop.midRate]);
    expect((TrenchBackdrop.farRate, TrenchBackdrop.midRate), (0.15, 0.35));
    expect(layers.first.tile, isA<TrenchWaterPainter>());
    expect(layers.last.tile, isA<TrenchRidgesPainter>());
    for (final layer in layers) {
      expect(layer.transform, same(transform));
      expect(layer.content, const Size(2000, 1000));
    }
    expect(find.ancestor(
        of: find.byType(ParallaxLayer).first,
        matching: find.byType(RepaintBoundary)), findsWidgets);
    // The soft water's bitmap at half the device's pixels, the crisp
    // ridges' at all of them.
    expect(tester.view.devicePixelRatio, 3);
    expect([for (final l in layers) l.resolution], [1.5, null]);
  });

  test('the water is never rasterized below a pixel per logical pixel', () {
    expect(TrenchBackdrop.waterResolution(3), 1.5);
    expect(TrenchBackdrop.waterResolution(2), 1);
    expect(TrenchBackdrop.waterResolution(1), 1);
  });

  group('the depth haze', () {
    testWidgets('lies still over its box, painted once from a small '
        'bitmap of its gradient, never tapped', (tester) async {
      await tester.pumpWidget(const DepthHaze());
      final haze = find.descendant(
          of: find.byType(DepthHaze), matching: find.byType(RasterPaint));
      final raster = tester.widget<RasterPaint>(haze);
      expect(raster.resolution, DepthHaze.resolution);
      expect(raster.resolution, lessThan(0.25));
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(tester.getSize(haze), size);
      expect((Canvas canvas) => raster.painter.paint(canvas, size),
          paints..rect(rect: Offset.zero & size));
      expect(find.ancestor(of: haze, matching: find.byType(RepaintBoundary)),
          findsWidgets);
      expect(find.ancestor(of: haze, matching: find.byType(IgnorePointer)),
          findsWidgets);
      // Its bitmap, stretched: the haze's opacity from top to bottom.
      final render = tester.renderObject<RenderRasterPaint>(haze);
      await settleRasters(tester, () => render.image != null);
      final image = render.image!;
      final bytes = (await tester.runAsync(() => image.toByteData()))!;
      int alphaAt(double share) => bytes.getUint8(
          ((share * (image.height - 1)).round() * image.width) * 4 + 3);
      final colours = AbyssTrenchTheme.haze.colors;
      expect(alphaAt(0), closeTo(colours.first.a * 255, 4));
      expect(alphaAt(0.7), closeTo(0, 4));
      expect(alphaAt(1), closeTo(colours.last.a * 255, 4));
    });

    test('is bluish high on the screen, clear in the middle, darker low',
        () {
      final colours = AbyssTrenchTheme.haze.colors;
      final stops = AbyssTrenchTheme.haze.stops!;
      expect(stops.first, 0);
      expect(stops.last, 1);
      final (top, middle, bottom) =
          (colours.first, colours[2], colours.last);
      expect(top.b, greaterThan(top.r));
      expect(top.a, greaterThan(bottom.a));
      expect(middle.a, 0);
      expect(bottom.a, greaterThan(middle.a));
      expect(bottom.computeLuminance(), lessThan(top.computeLuminance()));
    });
  });
}
