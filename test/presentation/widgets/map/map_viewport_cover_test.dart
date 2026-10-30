import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_backdrop.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_cell_size.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:abyss/presentation/widgets/map/viewport_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  // A diamond 200 wide and 100 tall, its top vertex at (100, 0).
  const diamond = [
    Offset(100, 0), Offset(200, 50), Offset(100, 100), Offset(0, 50)];
  const viewport = Size(40, 20);

  Matrix4 showing(Offset point, double scale) => Matrix4.translationValues(
      viewport.width / 2 - point.dx * scale,
      viewport.height / 2 - point.dy * scale, 0)
    ..scaleByDouble(scale, scale, 1, 1);

  test('a shape covers the viewport only when every corner lies in it', () {
    expect(coversViewport(diamond, showing(const Offset(100, 50), 1),
        viewport), isTrue);
    // Near the left vertex, the corners of the screen show the abyss.
    expect(coversViewport(diamond, showing(const Offset(20, 50), 1),
        viewport), isFalse);
    // Zoomed out, the viewport sees past the diamond.
    expect(coversViewport(diamond, showing(const Offset(100, 50), 0.2),
        viewport), isFalse);
  });

  test('the margin keeps clear of the shape\'s edges', () {
    final near = showing(const Offset(100, 30), 1);
    expect(coversViewport(diamond, near, viewport), isTrue);
    expect(coversViewport(diamond, near, viewport, margin: 12), isFalse);
  });

  test('the outline of a map is its floor, vertex to vertex', () {
    expect(MapProjection.outlineOf(3, 2), [
      MapProjection.toScreen(Offset.zero),
      MapProjection.toScreen(const Offset(3 * cellSize, 0)),
      MapProjection.toScreen(const Offset(3 * cellSize, 2 * cellSize)),
      MapProjection.toScreen(const Offset(0, 2 * cellSize)),
    ]);
  });

  group('on the map', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<TransformationController> pumpView(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GameMapView(
            gameMap: MapGenerator.generate(seed: 42).map,
            revealedCells: const {},
            baseX: 10,
            baseY: 10,
            humanPlayerId: 'human',
          ),
        ),
      ));
      return tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!;
    }

    bool trenchShows(WidgetTester tester) => find
        .byType(TrenchBackdrop, skipOffstage: true)
        .evaluate()
        .isNotEmpty;

    testWidgets('the trench is left unpainted while the floor fills the '
        'screen, its bitmaps kept for when the abyss shows', (tester) async {
      final controller = await pumpView(tester);
      final home = controller.value.clone();
      expect(find.byType(TrenchBackdrop, skipOffstage: false), findsOneWidget);
      expect(trenchShows(tester), isFalse);
      final viewport = tester.getSize(find.byType(InteractiveViewer));
      final scale = MapViewFit.overviewScale(
          viewport, MapProjection.sizeOf(20, 20));
      controller.value = Matrix4.diagonal3Values(scale, scale, scale);
      await tester.pump();
      expect(trenchShows(tester), isTrue);
      final layers = find.byType(RasterPaint);
      final bitmaps = [
        for (final e in layers.evaluate())
          (e.renderObject! as RenderRasterPaint).image,
      ];
      expect(bitmaps, everyElement(isNotNull));
      controller.value = home;
      await tester.pump();
      expect(trenchShows(tester), isFalse);
      controller.value = Matrix4.diagonal3Values(scale, scale, scale);
      await tester.pump();
      expect([
        for (final e in layers.evaluate())
          (e.renderObject! as RenderRasterPaint).image,
      ], bitmaps);
    });
  });
}
