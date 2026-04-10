import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
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
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.hard,
          unitCount: 100,
        ),
      );
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: cell, isRevealed: true),
      ));
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets('transition base not captured shows red glow',
        (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.transitionBase,
        transitionBase: TransitionBase(
          type: TransitionBaseType.faille,
          name: 'Test Faille',
        ),
      );
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: cell, isRevealed: true),
      ));
      expect(find.byIcon(Icons.electric_bolt), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.electric_bolt));
      expect(icon.color, AbyssColors.error);
    });

    testWidgets('transition base captured shows cyan glow',
        (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.transitionBase,
        transitionBase: TransitionBase(
          type: TransitionBaseType.faille,
          name: 'Test Faille',
          capturedBy: 'player-id',
        ),
      );
      await tester.pumpWidget(wrap(
        MapCellWidget(
          cell: cell,
          isRevealed: true,
          isCapturedTransitionBase: true,
        ),
      ));
      expect(find.byIcon(Icons.electric_bolt), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.electric_bolt));
      expect(icon.color, AbyssColors.biolumCyan);
    });

    testWidgets('transition base not revealed has no icon',
        (tester) async {
      final cell = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.transitionBase,
        transitionBase: TransitionBase(
          type: TransitionBaseType.faille,
          name: 'Test Faille',
        ),
      );
      await tester.pumpWidget(wrap(
        MapCellWidget(cell: cell, isRevealed: false),
      ));
      expect(find.byIcon(Icons.electric_bolt), findsNothing);
    });
  });
}
