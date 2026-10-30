import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'map_view_geometry.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);
  final map = MapProjection.sizeOf(20, 20);

  /// A phone's screen, where the map first shows zoomed below 1.
  Future<void> pumpOnPhone(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390 * 3, 844 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
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
  }

  Finder viewer() => find.byType(InteractiveViewer);

  void expectCentredOverview(WidgetTester tester, String when) {
    final viewport = tester.getSize(viewer());
    final overview = MapViewFit.overviewScale(viewport, map);
    final transform = mapTransformOf(tester);
    expect(transform.storage[0], closeTo(overview, 1e-6), reason: when);
    expect(transform.getMaxScaleOnAxis(), closeTo(overview, 1e-6),
        reason: when);
    final topLeft =
        mapPointOnScreen(tester, -MapProjection.originOf(20), rows: 20);
    final shown = topLeft & map * transform.storage[0];
    expect((shown.center - tester.getCenter(viewer())).distance,
        lessThan(1), reason: when);
  }

  testWidgets('the map first shows at the scale it reports', (tester) async {
    await pumpOnPhone(tester);
    final transform = mapTransformOf(tester);
    expect(transform.storage[0], lessThan(1));
    expect(transform.getMaxScaleOnAxis(), closeTo(transform.storage[0], 1e-9));
  });

  testWidgets('zoomed fully out with the mouse wheel, the map floats in the '
      'middle and a drag leaves it there', (tester) async {
    await pumpOnPhone(tester);
    final centre = tester.getCenter(viewer());
    final mouse = TestPointer(1, PointerDeviceKind.mouse)..hover(centre);
    for (var notch = 0; notch < 40; notch++) {
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 100)));
      await tester.pump();
    }
    expectCentredOverview(tester, 'after the wheel');
    await tester.dragFrom(centre, const Offset(-60, 80));
    await tester.pump(const Duration(seconds: 2));
    expectCentredOverview(tester, 'after a drag');
  });
}
