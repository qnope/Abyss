import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map_tile_widget.dart';

void main() {
  group('MapTileWidget', () {
    Widget createApp({required MapTile tile, VoidCallback? onTap}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: SizedBox(
            width: 48,
            height: 48,
            child: MapTileWidget(tile: tile, onTap: onTap ?? () {}),
          ),
        ),
      );
    }

    testWidgets('shows question mark for hidden tile', (tester) async {
      final tile = MapTile(x: 0, y: 0, terrain: TerrainType.plain);
      await tester.pumpWidget(createApp(tile: tile));
      expect(find.byIcon(Icons.question_mark), findsOneWidget);
    });

    testWidgets('shows no icon for revealed empty tile', (tester) async {
      final tile = MapTile(
        x: 0, y: 0, terrain: TerrainType.plain, revealed: true);
      await tester.pumpWidget(createApp(tile: tile));
      expect(find.byIcon(Icons.question_mark), findsNothing);
    });

    testWidgets('shows home icon for player base', (tester) async {
      final tile = MapTile(
        x: 10, y: 10, terrain: TerrainType.plain,
        content: TileContent.playerBase, revealed: true);
      await tester.pumpWidget(createApp(tile: tile));
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('shows pest_control for monster', (tester) async {
      final tile = MapTile(
        x: 5, y: 5, terrain: TerrainType.rock,
        content: TileContent.monsterLevel1, revealed: true);
      await tester.pumpWidget(createApp(tile: tile));
      expect(find.byIcon(Icons.pest_control), findsOneWidget);
    });

    testWidgets('shows shield for enemy', (tester) async {
      final tile = MapTile(
        x: 3, y: 3, terrain: TerrainType.reef,
        content: TileContent.enemy, revealed: true);
      await tester.pumpWidget(createApp(tile: tile));
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final tile = MapTile(
        x: 0, y: 0, terrain: TerrainType.plain, revealed: true);
      await tester.pumpWidget(
        createApp(tile: tile, onTap: () => tapped = true));
      await tester.tap(find.byType(MapTileWidget));
      expect(tapped, isTrue);
    });
  });
}
