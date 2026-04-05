import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/monster_detail_sheet.dart';

void main() {
  group('MonsterDetailSheet', () {
    Widget createApp(MapTile tile) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showMonsterDetailSheet(context, tile: tile),
              child: const Text('Open'),
            ),
          ),
        ),
      );
    }

    testWidgets('shows level 1 monster info', (tester) async {
      final tile = MapTile(
        x: 5, y: 5, terrain: TerrainType.rock,
        content: TileContent.monsterLevel1, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Créature de niveau 1'), findsOneWidget);
      expect(find.text('Faible'), findsOneWidget);
    });

    testWidgets('shows level 3 monster info', (tester) async {
      final tile = MapTile(
        x: 1, y: 1, terrain: TerrainType.fault,
        content: TileContent.monsterLevel3, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Créature de niveau 3'), findsOneWidget);
      expect(find.text('Dangereux'), findsOneWidget);
    });

    testWidgets('attack button is disabled', (tester) async {
      final tile = MapTile(
        x: 5, y: 5, terrain: TerrainType.rock,
        content: TileContent.monsterLevel1, revealed: true);
      await tester.pumpWidget(createApp(tile));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Attaquer'), findsOneWidget);
    });
  });
}
