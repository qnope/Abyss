import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/depth_haze.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/parallax_layer.dart';
import 'package:abyss/presentation/widgets/backdrop/trench/trench_backdrop.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_snow_layer.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'map_view_geometry.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);
  final map = MapProjection.sizeOf(20, 20);

  Future<void> pumpView(WidgetTester tester) => tester.pumpWidget(MaterialApp(
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

  Finder viewer() => find.byType(InteractiveViewer);
  TransformationController controllerOf(WidgetTester tester) =>
      tester.widget<InteractiveViewer>(viewer()).transformationController!;

  testWidgets('the trench lies behind the map, the haze and the snow over '
      'it, all following the map', (tester) async {
    await pumpView(tester);
    final widgets = tester.allWidgets.toList();
    int indexOf<T>() => widgets.indexWhere((w) => w is T);
    expect(indexOf<TrenchBackdrop>(), lessThan(indexOf<InteractiveViewer>()));
    expect(indexOf<InteractiveViewer>(), lessThan(indexOf<DepthHaze>()));
    expect(indexOf<DepthHaze>(), lessThan(indexOf<MapSnowLayer>()));
    final backdrop = tester.widget<TrenchBackdrop>(
        find.byType(TrenchBackdrop, skipOffstage: false));
    final snow = tester.widget<MapSnowLayer>(find.byType(MapSnowLayer));
    expect(backdrop.transform, same(controllerOf(tester)));
    expect(snow.transform, same(controllerOf(tester)));
    expect((backdrop.content, snow.content), (map, map));
    for (final layer in [TrenchBackdrop, DepthHaze, MapSnowLayer]) {
      expect(tester.getRect(find.byType(layer, skipOffstage: false)),
          tester.getRect(viewer()));
    }
  });

  testWidgets('panning slides the trench, never repainting it, the haze or '
      'the still map with its slab', (tester) async {
    await pumpView(tester);
    // Zoomed out, the map in the middle, so that the abyss shows around.
    final screen = tester.getSize(viewer());
    final scale = MapViewFit.overviewScale(screen, map);
    final corner = (screen - map * scale as Offset) / 2;
    controllerOf(tester).value =
        Matrix4.translationValues(corner.dx, corner.dy, 0)
          ..scaleByDouble(scale, scale, scale, 1);
    await tester.pump();
    RenderRepaintBoundary boundaryOver(Finder finder) => tester
        .renderObject<RenderRepaintBoundary>(find
            .ancestor(of: finder, matching: find.byType(RepaintBoundary))
            .first);
    final boundaries = [
      for (final element in find
          .descendant(
              of: find.byType(ParallaxLayer),
              matching: find.byType(RasterPaint))
          .evaluate())
        boundaryOver(find.byWidget(element.widget)),
      boundaryOver(find.descendant(
          of: find.byType(DepthHaze), matching: find.byType(RasterPaint))),
      boundaryOver(find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is MapPainter)),
    ];
    expect(boundaries, hasLength(4));
    // A repaint records a new picture into the boundary's layer.
    Layer? pictureOf(RenderRepaintBoundary b) => b.debugLayer!.firstChild;
    final before = boundaries.map(pictureOf).toList();
    expect(before, everyElement(isA<PictureLayer>()));
    // Unlike the standing contents, culled to the screen as it pans.
    final standing = boundaryOver(find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MapStandingPainter));
    final culled = pictureOf(standing);
    final shifts = find.descendant(
        of: find.byType(ParallaxLayer), matching: find.byType(Transform));
    double shiftOf(int i) =>
        tester.widget<Transform>(shifts.at(i)).transform.storage[13];
    final (far, mid) = (shiftOf(0), shiftOf(1));
    final controller = controllerOf(tester);
    controller.value = controller.value.clone()
      ..translateByDouble(0, -30 / controller.value.getMaxScaleOnAxis(), 0, 1);
    await tester.pump();
    for (final (i, boundary) in boundaries.indexed) {
      expect(pictureOf(boundary), same(before[i]), reason: '$i');
    }
    expect(pictureOf(standing), isNot(same(culled)));
    expect(shiftOf(0) - far, closeTo(TrenchBackdrop.farRate * -30, 1e-6));
    expect(shiftOf(1) - mid, closeTo(TrenchBackdrop.midRate * -30, 1e-6));
  });

  testWidgets('zoomed out the most, the whole map and its slab float in the '
      'middle of the abyss', (tester) async {
    await pumpView(tester);
    final viewport = tester.getSize(viewer());
    final overview = MapViewFit.overviewScale(viewport, map);
    expect(tester.widget<InteractiveViewer>(viewer()).minScale, overview);
    final centre = tester.getCenter(viewer());
    for (var pinch = 0; pinch < 4; pinch++) {
      final a = await tester.startGesture(centre.translate(-200, 0));
      final b = await tester.startGesture(centre.translate(200, 0));
      for (var step = 1; step <= 10; step++) {
        await a.moveTo(centre.translate(-200 + 19.0 * step, 0));
        await b.moveTo(centre.translate(200 - 19.0 * step, 0));
        await tester.pump();
      }
      await a.up();
      await b.up();
      // Lets the fling end; the ambience never settles.
      await tester.pump(const Duration(seconds: 2));
    }
    final scale = mapTransformOf(tester).getMaxScaleOnAxis();
    expect(scale, closeTo(overview, 1e-6));
    final topLeft = mapPointOnScreen(tester, -MapProjection.originOf(20),
        rows: 20);
    final shown = topLeft & map * scale;
    final screen = tester.getRect(viewer());
    expect(screen.contains(shown.topLeft), isTrue);
    expect(screen.contains(shown.bottomRight), isTrue);
    expect((shown.center - screen.center).distance, lessThan(1));
  });
}
