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

  bool hasFogOverlay(WidgetTester tester) {
    final containers = tester.widgetList<Container>(find.byType(Container));
    return containers.any(
      (c) => c.color == AbyssColors.abyssBlack.withValues(alpha: 0.7),
    );
  }

  MapCell plainBonus({String? collectedBy}) => MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.resourceBonus,
        collectedBy: collectedBy,
      );

  group('MapCellWidget', () {
    testWidgets('unrevealed cell has fog overlay', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: plainBonus(), isRevealed: false),
      ));
      expect(hasFogOverlay(tester), isTrue);
    });

    testWidgets('revealed cell has no fog overlay', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: plainBonus(), isRevealed: true),
      ));
      expect(hasFogOverlay(tester), isFalse);
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('revealed + not collected → no opacity wrapper',
        (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: plainBonus(), isRevealed: true),
      ));
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('revealed + collected by human → opacity 0.3', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(
          cell: plainBonus(collectedBy: 'human-uuid'),
          isRevealed: true,
        ),
      ));
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.3);
    });

    testWidgets('revealed + collected by other → opacity 0.3', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(
          cell: plainBonus(collectedBy: 'other-uuid'),
          isRevealed: true,
          isCollectedByOther: true,
        ),
      ));
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.3);
    });

    testWidgets('isBase=true renders player base SVG', (tester) async {
      await tester.pumpWidget(wrap(
        MapCellWidget(
          cell: MapCell(terrain: TerrainType.plain),
          isRevealed: true,
          isBase: true,
        ),
      ));
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('monster lair shows monster SVG when revealed',
        (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        monsterDifficulty: MonsterDifficulty.hard,
      );
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: cell, isRevealed: true),
      ));
      expect(find.byType(SvgPicture), findsWidgets);
    });
  });
}
