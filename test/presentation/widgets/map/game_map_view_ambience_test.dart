import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_snow_painter.dart';
import 'package:abyss/presentation/widgets/map/map_standing_hit.dart';
import 'package:abyss/presentation/widgets/map/map_standing_painter.dart';
import 'package:abyss/presentation/widgets/map/scout_token_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import 'map_view_geometry.dart';

void main() {
  setUp(() => mockSvgAssets());
  tearDown(() => clearSvgMocks());

  Future<void> pumpView(WidgetTester tester,
      {void Function(int x, int y)? onCellTap,
      Set<(int, int)> pendingTargets = const {},
      Set<GridPosition> revealedCells = const {}}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameMapView(
          gameMap: MapGenerator.generate(seed: 42).map,
          revealedCells: revealedCells,
          baseX: 10,
          baseY: 10,
          humanPlayerId: 'human',
          onCellTap: onCellTap,
          pendingTargets: pendingTargets,
        ),
      ),
    ));
  }

  T painterOf<T>(WidgetTester tester) => tester
      .widget<CustomPaint>(find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is T))
      .painter! as T;

  testWidgets('a standing layer draws the contents over the still map', (
    tester,
  ) async {
    await pumpView(tester);
    final map = painterOf<MapPainter>(tester);
    final standing = painterOf<MapStandingPainter>(tester);
    expect(standing.visuals, same(map.visuals));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(standing.transform, same(viewer.transformationController));
    expect(standing.viewport, tester.getSize(find.byType(InteractiveViewer)));
    final before = standing.clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(standing.clock.value, greaterThan(before));
  });

  testWidgets('the marine snow lies over the screen, not the map', (
    tester,
  ) async {
    await pumpView(tester);
    final snow = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is MapSnowPainter);
    expect(snow, findsOneWidget);
    expect(find.descendant(of: find.byType(InteractiveViewer), matching: snow),
        findsNothing);
    expect(find.ancestor(of: snow, matching: find.byType(IgnorePointer)),
        findsWidgets);
    expect(tester.getSize(snow), tester.getSize(find.byType(InteractiveViewer)));
  });

  testWidgets('scouts sent wait on their targets, set off from the base', (
    tester,
  ) async {
    await pumpView(tester, pendingTargets: {(11, 11)});
    final layer = tester.widget<ScoutTokenLayer>(find.byType(ScoutTokenLayer));
    expect(layer.targets, {(11, 11)});
    expect(layer.originOf((11, 11)), (10, 10));
    expect(find.ancestor(
        of: find.byType(ScoutTokenLayer),
        matching: find.byType(RepaintBoundary)), findsWidgets);
  });

  testWidgets('taps still reach the cell under the pointer', (tester) async {
    (int, int)? tapped;
    await pumpView(tester,
        onCellTap: (x, y) => tapped = (x, y), pendingTargets: {(10, 10)});
    await tester.tapAt(mapPointOnScreen(
        tester, MapProjection.centreOf((10, 10)), rows: 20));
    expect(tapped, (10, 10));
  });

  testWidgets('a tap on the top of a tall sprite picks its cell', (
    tester,
  ) async {
    (int, int)? tapped;
    await pumpView(tester,
        onCellTap: (x, y) => tapped = (x, y),
        revealedCells: {GridPosition(x: 10, y: 10)});
    final top = standingHitBox(MapProjection.standingOf((10, 10)))
        .topCenter
        .translate(0, 3);
    await tester.tapAt(mapPointOnScreen(tester, top, rows: 20));
    expect(tapped, (10, 10));
  });

  testWidgets('reduced motion freezes the map, which can settle', (
    tester,
  ) async {
    reduceMotion(tester);
    await pumpView(tester);
    await tester.pumpAndSettle();
    final clock = painterOf<MapStandingPainter>(tester).clock;
    final before = clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, before);
    expect(painterOf<MapSnowPainter>(tester).clock, same(clock));
  });
}
