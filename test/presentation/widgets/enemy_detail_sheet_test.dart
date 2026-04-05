import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/enemy_detail_sheet.dart';

void main() {
  group('EnemyDetailSheet', () {
    Widget createApp(MapTile tile) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showEnemyDetailSheet(context, tile: tile),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows enemy faction name', (tester) async {
      final tile = MapTile(
        x: 3, y: 3, terrain: TerrainType.plain,
        content: TileContent.enemy, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.text('Neutre'), findsOneWidget);
    });

    testWidgets('shows action buttons', (tester) async {
      final tile = MapTile(
        x: 3, y: 3, terrain: TerrainType.plain,
        content: TileContent.enemy, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Attaquer'), findsOneWidget);
      expect(find.text('Diplomatie'), findsOneWidget);
      expect(find.text('Espionner'), findsOneWidget);
    });
  });
}
