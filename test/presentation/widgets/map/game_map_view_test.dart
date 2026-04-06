import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import 'package:abyss/presentation/widgets/map/map_cell_widget.dart';

void main() {
  group('GameMapView', () {
    testWidgets('renders without error', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GameMapView), findsOneWidget);
    });

    testWidgets('contains InteractiveViewer', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('renders 400 MapCellWidgets', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MapCellWidget), findsNWidgets(400));
    });

    testWidgets('maxScale allows zoom to 1 visible cell', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.maxScale, closeTo(800.0 / (1.0 * 48.0), 0.01));
    });

    testWidgets('minScale allows full map to be visible', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.minScale, closeTo(800.0 / (20 * 48.0), 0.01));
    });

    testWidgets('initial scale shows 8 visible cells', (tester) async {
      final map = MapGenerator.generate(seed: 42);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameMapView(gameMap: map))),
      );
      await tester.pumpAndSettle();
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final matrix = viewer.transformationController!.value;
      final scale = matrix.getMaxScaleOnAxis();
      expect(scale, closeTo(800.0 / (8.0 * 48.0), 0.01));
    });
  });
}
