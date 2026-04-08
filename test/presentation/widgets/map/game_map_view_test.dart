import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_cell_widget.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(() => mockSvgAssets());
  tearDown(() => clearSvgMocks());

  Future<void> pumpView(
    WidgetTester tester, {
    required Set<GridPosition> revealedCells,
    int baseX = 10,
    int baseY = 10,
    String humanPlayerId = 'human-uuid',
  }) async {
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
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('GameMapView', () {
    testWidgets('renders 400 MapCellWidgets in 20x20 grid', (tester) async {
      await pumpView(tester, revealedCells: {});
      expect(find.byType(MapCellWidget), findsNWidgets(400));
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
      final widgets = tester
          .widgetList<MapCellWidget>(find.byType(MapCellWidget))
          .toList();
      expect(widgets[0].isRevealed, isTrue);
      expect(widgets[1].isRevealed, isTrue);
      expect(widgets[2].isRevealed, isFalse);
    });

    testWidgets('marks the cell at (baseX, baseY) as isBase', (tester) async {
      await pumpView(tester, revealedCells: {}, baseX: 5, baseY: 7);
      final widgets = tester
          .widgetList<MapCellWidget>(find.byType(MapCellWidget))
          .toList();
      final baseWidget = widgets[7 * 20 + 5];
      expect(baseWidget.isBase, isTrue);
      final nonBase = widgets[7 * 20 + 6];
      expect(nonBase.isBase, isFalse);
    });

    testWidgets('initial scale shows 8 visible cells', (tester) async {
      await pumpView(tester, revealedCells: {});
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final scale =
          viewer.transformationController!.value.getMaxScaleOnAxis();
      expect(scale, closeTo(800.0 / (8.0 * 48.0), 0.01));
    });
  });
}
