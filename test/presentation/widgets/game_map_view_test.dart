import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game_map.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/game_map_view.dart';
import 'package:abyss/presentation/widgets/map_tile_widget.dart';

void main() {
  group('GameMapView', () {
    late GameMap gameMap;

    setUp(() {
      final tiles = [
        for (int y = 0; y < 20; y++)
          for (int x = 0; x < 20; x++)
            MapTile(
              x: x, y: y,
              terrain: TerrainType.plain,
              content: x == 10 && y == 10
                  ? TileContent.playerBase
                  : TileContent.empty,
              revealed: true,
            ),
      ];
      gameMap = GameMap(tiles: tiles);
    });

    Widget createApp({MapTile? tappedTile}) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: GameMapView(
            gameMap: gameMap,
            onTileTap: (_) {},
          ),
        ),
      );
    }

    testWidgets('renders InteractiveViewer', (tester) async {
      await tester.pumpWidget(createApp());
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('renders MapTileWidget tiles', (tester) async {
      await tester.pumpWidget(createApp());
      expect(find.byType(MapTileWidget), findsWidgets);
    });

    testWidgets('calls onTileTap when a tile is tapped', (tester) async {
      MapTile? tapped;
      await tester.pumpWidget(MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: GameMapView(
            gameMap: gameMap,
            onTileTap: (tile) => tapped = tile,
          ),
        ),
      ));
      await tester.tap(find.byType(MapTileWidget).first);
      expect(tapped, isNotNull);
    });
  });
}
