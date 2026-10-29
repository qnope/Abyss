import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effects.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'map_view_geometry.dart';

class _Run implements MapEffectRun {
  @override
  Duration get duration => const Duration(seconds: 1);

  @override
  Offset shakeAt(Duration elapsed) => Offset.zero;

  @override
  void paint(Canvas canvas, Duration elapsed) {}
}

class _Focused extends MapEffect {
  @override
  final (int, int) focus;

  const _Focused(this.focus);

  @override
  MapEffectRun stage(MapStage stage) => _Run();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  /// The 20 by 20 map seen from its base at (6, 13) on an 800 px screen.
  Future<void> pumpView(WidgetTester tester, {MapEffects? effects}) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GameMapView(
            gameMap: MapGenerator.generate(seed: 42).map,
            revealedCells: const {},
            baseX: 6,
            baseY: 13,
            humanPlayerId: 'human',
            effects: effects,
          ),
        ),
      ));

  /// How far the [cell] shows from the middle of the map's screen.
  double offCentre(WidgetTester tester, (int, int) cell) {
    final middle = tester.getCenter(find.byType(InteractiveViewer));
    final shown = mapPointOnScreen(tester, MapProjection.centreOf(cell),
        rows: 20);
    return (shown - middle).distance;
  }

  final homeScale = 800.0 / (4.5 * MapProjection.tileWidth);

  testWidgets('the base shows in the middle, four tiles and a half across', (
    tester,
  ) async {
    await pumpView(tester);
    expect(offCentre(tester, (6, 13)), lessThan(0.01));
    expect(mapTransformOf(tester).getMaxScaleOnAxis(), closeTo(homeScale, 1e-9));
  });

  testWidgets('zooms from the whole map width to a tile and a half', (
    tester,
  ) async {
    await pumpView(tester);
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.minScale,
        closeTo(800.0 / MapProjection.sizeOf(20, 20).width, 1e-9));
    expect(viewer.maxScale,
        closeTo(800.0 / (1.5 * MapProjection.tileWidth), 1e-9));
  });

  testWidgets('an effect playing centres the map on its focus', (
    tester,
  ) async {
    final effects = MapEffects();
    addTearDown(effects.dispose);
    effects.play(const _Focused((15, 4)), awaitStage: true);
    await pumpView(tester, effects: effects);
    expect(offCentre(tester, (15, 4)), lessThan(0.01));
    expect(mapTransformOf(tester).getMaxScaleOnAxis(), closeTo(homeScale, 1e-9));
    effects.finish();
  });

  test('centredOn puts the projected cell in the middle of the screen', () {
    const screen = Size(400, 700);
    final matrix =
        MapViewport.centeredOn(screen, (3, 7), rows: 12, visibleTiles: 4);
    expect(matrix.getMaxScaleOnAxis(),
        closeTo(400 / (4 * MapProjection.tileWidth), 1e-9));
    final centre = MapProjection.originOf(12) + MapProjection.centreOf((3, 7));
    final shown = MatrixUtils.transformPoint(matrix, centre);
    expect((shown - screen.center(Offset.zero)).distance, lessThan(1e-9));
  });
}
