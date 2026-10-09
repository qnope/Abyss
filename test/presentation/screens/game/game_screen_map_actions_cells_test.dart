import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_army_selection_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/map_tab_harness.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> tapCellWith(
    WidgetTester tester,
    MapCell cell, {
    int x = 2,
    int y = 2,
  }) async {
    final game = harnessGame(plainMap({GridPosition(x: x, y: y): cell}));
    await tester.pumpWidget(mapTabHost(game));
    await tester.pumpAndSettle();
    await tapMapCell(tester, x, y);
  }

  MapCell cellOf(CellContentType content, {String? collectedBy}) => MapCell(
        terrain: TerrainType.plain,
        content: content,
        collectedBy: collectedBy,
      );

  testWidgets('an already collected cell says it was visited',
      (tester) async {
    await tapCellWith(
      tester,
      cellOf(CellContentType.ruins, collectedBy: 'someone'),
    );
    expect(find.text('Déjà visité'), findsOneWidget);
    expect(find.text('Vous êtes déjà venu par ici'), findsOneWidget);
  });

  testWidgets('the base cell shows the headquarters', (tester) async {
    await tapCellWith(tester, cellOf(CellContentType.empty), x: 5, y: 5);
    expect(find.text('Votre base'), findsOneWidget);
    expect(find.text('Votre quartier général'), findsOneWidget);
  });

  testWidgets('an empty cell shows a plain', (tester) async {
    await tapCellWith(tester, cellOf(CellContentType.empty), x: 1, y: 4);
    expect(find.text('Plaine (1, 4)'), findsOneWidget);
    expect(find.text("Il n'y a rien a voir ici"), findsOneWidget);
  });

  testWidgets('a transition base cell without base acts as a plain',
      (tester) async {
    await tapCellWith(tester, cellOf(CellContentType.transitionBase));
    expect(find.text('Plaine (2, 2)'), findsOneWidget);
  });

  testWidgets('a named passage shows its destination', (tester) async {
    await tapCellWith(
      tester,
      MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.passage,
        passageName: 'la Fosse',
      ),
    );
    expect(find.text('Passage vers la Fosse'), findsOneWidget);
  });

  testWidgets('an unnamed passage falls back to unknown', (tester) async {
    await tapCellWith(tester, cellOf(CellContentType.passage));
    expect(find.text('Passage vers passage inconnu'), findsOneWidget);
  });

  testWidgets('a monster lair opens the army selection', (tester) async {
    await tapCellWith(
      tester,
      MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 3,
        ),
      ),
    );
    expect(find.text('Rôdeurs (2, 2)'), findsOneWidget);

    await tester.tap(find.text('Préparer le combat'));
    await tester.pumpAndSettle();

    expect(find.byType(ArmySelectionScreen), findsOneWidget);
  });

  testWidgets('an uncaptured volcanic kernel can be assaulted',
      (tester) async {
    await tapCellWith(tester, cellOf(CellContentType.volcanicKernel));
    expect(find.text('Noyau Volcanique'), findsOneWidget);

    await tester.tap(find.text("Lancer l'assaut"));
    await tester.pumpAndSettle();

    expect(find.byType(KernelArmySelectionScreen), findsOneWidget);
  });
}
