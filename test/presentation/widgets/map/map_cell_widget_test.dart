import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/map_cell_widget.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('MapCellWidget', () {
    testWidgets('revealed cell has no fog overlay', (tester) async {
      final cell = MapCell(
        terrain: TerrainType.reef,
        isRevealed: true,
      );
      await tester.pumpWidget(wrap(MapCellWidget(cell: cell)));
      final svgs = find.byType(SvgPicture);
      expect(svgs, findsWidgets);
    });

    testWidgets('unrevealed cell has fog overlay', (tester) async {
      final cell = MapCell(terrain: TerrainType.reef);
      await tester.pumpWidget(wrap(MapCellWidget(cell: cell)));
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );
      final hasFog = containers.any(
        (c) => c.color == AbyssColors.abyssBlack.withValues(alpha: 0.7),
      );
      expect(hasFog, isTrue);
    });

    testWidgets('base cell shows player_base SVG', (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        isRevealed: true,
      );
      await tester.pumpWidget(
        wrap(MapCellWidget(cell: cell, isBase: true)),
      );
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('monster lair shows monster SVG', (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        monsterDifficulty: MonsterDifficulty.hard,
        isRevealed: true,
      );
      await tester.pumpWidget(wrap(MapCellWidget(cell: cell)));
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('resource bonus shows resource SVG', (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.resourceBonus,
        isRevealed: true,
      );
      await tester.pumpWidget(wrap(MapCellWidget(cell: cell)));
      expect(find.byType(SvgPicture), findsWidgets);
    });
  });
}
