import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_ambience_painter.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_snow_painter.dart';
import 'package:abyss/presentation/widgets/map/scout_token_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(() => mockSvgAssets());
  tearDown(() => clearSvgMocks());

  Future<void> pumpView(WidgetTester tester,
      {void Function(int x, int y)? onCellTap,
      Set<(int, int)> pendingTargets = const {}}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GameMapView(
          gameMap: MapGenerator.generate(seed: 42).map,
          revealedCells: const {},
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

  testWidgets('an ambience layer moves the contents of the static map', (
    tester,
  ) async {
    await pumpView(tester);
    final map = painterOf<MapPainter>(tester);
    final ambience = painterOf<MapAmbiencePainter>(tester);
    expect(ambience.visuals, same(map.visuals));
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(ambience.transform, same(viewer.transformationController));
    expect(ambience.viewport, tester.getSize(find.byType(InteractiveViewer)));
    final before = ambience.clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(ambience.clock.value, greaterThan(before));
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
    final viewer = find.byType(InteractiveViewer);
    final matrix =
        tester.widget<InteractiveViewer>(viewer).transformationController!.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = Offset(matrix.storage[12], matrix.storage[13]);
    const center = Offset(10.5 * cellSize, 10.5 * cellSize);
    await tester.tapAt(tester.getTopLeft(viewer) + translation + center * scale);
    expect(tapped, (10, 10));
  });

  testWidgets('reduced motion freezes the map, which can settle', (
    tester,
  ) async {
    reduceMotion(tester);
    await pumpView(tester);
    await tester.pumpAndSettle();
    final clock = painterOf<MapAmbiencePainter>(tester).clock;
    final before = clock.value;
    await tester.pump(const Duration(seconds: 1));
    expect(clock.value, before);
    expect(painterOf<MapSnowPainter>(tester).clock, same(clock));
  });
}
