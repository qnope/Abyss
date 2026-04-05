import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tile_detail_sheet.dart';

void main() {
  group('TileDetailSheet', () {
    Widget createApp(MapTile tile) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTileDetailSheet(context, tile: tile),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows hidden tile info', (tester) async {
      final tile = MapTile(x: 5, y: 5, terrain: TerrainType.plain);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Zone inexplorée'), findsOneWidget);
      expect(find.text('Explorer'), findsOneWidget);
    });

    testWidgets('shows empty revealed tile info', (tester) async {
      final tile = MapTile(
        x: 5, y: 5, terrain: TerrainType.reef, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Récif corallien'), findsOneWidget);
    });

    testWidgets('shows player base info', (tester) async {
      final tile = MapTile(
        x: 10, y: 10, terrain: TerrainType.plain,
        content: TileContent.playerBase, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Votre base'), findsOneWidget);
    });

    testWidgets('shows coordinates', (tester) async {
      final tile = MapTile(
        x: 7, y: 12, terrain: TerrainType.rock, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('(7, 12)'), findsOneWidget);
    });
  });
}
