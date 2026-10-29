import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import 'map_view_geometry.dart';

void main() {
  setUp(() => mockSvgAssets());
  tearDown(() => clearSvgMocks());

  Future<void> pumpView(
    WidgetTester tester, {
    required Set<GridPosition> revealedCells,
    int baseX = 10,
    int baseY = 10,
    String humanPlayerId = 'human-uuid',
    void Function(int x, int y)? onCellTap,
  }) async {
    reduceMotion(tester);
    final result = MapGenerator.generate(seed: 42);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameMapView(
            gameMap: result.map,
            revealedCells: revealedCells,
            baseX: baseX,
            baseY: baseY,
            humanPlayerId: humanPlayerId,
            onCellTap: onCellTap,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<MapCellVisual> visualsOf(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is MapPainter,
    ));
    return (paint.painter! as MapPainter).visuals;
  }

  Offset onScreen(WidgetTester tester, Offset point) =>
      mapPointOnScreen(tester, point, rows: 20);

  group('GameMapView', () {
    testWidgets('paints 400 cells in a single painter', (tester) async {
      await pumpView(tester, revealedCells: {});
      expect(visualsOf(tester), hasLength(400));
      final painter = tester
          .widget<CustomPaint>(find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is MapPainter,
          ))
          .size;
      expect(painter, MapProjection.sizeOf(20, 20));
    });

    testWidgets('tap reports the cell under the pointer', (tester) async {
      (int, int)? tapped;
      await pumpView(
        tester,
        revealedCells: {},
        onCellTap: (x, y) => tapped = (x, y),
      );
      await tester.tapAt(onScreen(tester, MapProjection.centreOf((10, 10))));
      expect(tapped, (10, 10));
      // Left of the projection's origin, on the bottom corner of a tile.
      final tile = MapProjection.tileRectOf((9, 11));
      await tester.tapAt(onScreen(tester, tile.bottomCenter.translate(0, -2)));
      expect(tapped, (9, 11));
    });

    testWidgets('contains InteractiveViewer', (tester) async {
      await pumpView(tester, revealedCells: {});
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('passes isRevealed=true for cells in revealedCells set',
        (tester) async {
      final revealed = {
        GridPosition(x: 0, y: 0),
        GridPosition(x: 1, y: 0),
      };
      await pumpView(tester, revealedCells: revealed);
      final visuals = visualsOf(tester);
      expect(visuals[0].revealed, isTrue);
      expect(visuals[1].revealed, isTrue);
      expect(visuals[2].revealed, isFalse);
    });

    testWidgets('marks the cell at (baseX, baseY) as isBase', (tester) async {
      final revealed = {
        GridPosition(x: 5, y: 7),
        GridPosition(x: 6, y: 7),
      };
      await pumpView(tester, revealedCells: revealed, baseX: 5, baseY: 7);
      final visuals = visualsOf(tester);
      expect(visuals[7 * 20 + 5].contentSprite, playerBaseSvgPath);
      expect(visuals[7 * 20 + 6].contentSprite, isNot(playerBaseSvgPath));
    });

    testWidgets('no cell is marked as base when baseX/baseY are null',
        (tester) async {
      reduceMotion(tester);
      final result = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameMapView(
              gameMap: result.map,
              revealedCells: {GridPosition(x: 10, y: 10)},
              humanPlayerId: 'human-uuid',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final visuals = visualsOf(tester);
      expect(
        visuals.any((v) => v.contentSprite == playerBaseSvgPath),
        isFalse,
      );
    });
  });
}
