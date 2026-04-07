import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_map_actions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('Collect treasure flow dialog wiring', () {
    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    const treasureX = 3;
    const treasureY = 3;

    GameMap buildTestMap(CellContentType content) {
      final cells = List.generate(
        20 * 20,
        (_) => MapCell(terrain: TerrainType.plain, isRevealed: true),
      );
      cells[treasureY * 20 + treasureX] = MapCell(
        terrain: TerrainType.plain,
        content: content,
        isRevealed: true,
      );
      return GameMap(
        width: 20,
        height: 20,
        cells: cells,
        playerBaseX: 10,
        playerBaseY: 10,
        seed: 1,
      );
    }

    Widget buildHost(Game game) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                buildMapTab(context, game, FakeGameRepository(), () {}),
          ),
        ),
      );
    }

    Future<void> tapTreasureCell(WidgetTester tester) async {
      final view =
          tester.widget<GameMapView>(find.byType(GameMapView));
      view.onCellTap!(treasureX, treasureY);
      await tester.pumpAndSettle();
    }

    testWidgets('resourceBonus shows success dialog after collect',
        (tester) async {
      final game = Game(
        player: Player(name: 'Nemo'),
        gameMap: buildTestMap(CellContentType.resourceBonus),
      );
      await tester.pumpWidget(buildHost(game));
      await tester.pumpAndSettle();

      await tapTreasureCell(tester);
      expect(find.text('Collecter le trésor'), findsOneWidget);

      await tester.tap(find.text('Collecter le trésor'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Trésor collecté !'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('ruins shows ruins dialog after collect', (tester) async {
      final game = Game(
        player: Player(name: 'Nemo'),
        gameMap: buildTestMap(CellContentType.ruins),
      );
      await tester.pumpWidget(buildHost(game));
      await tester.pumpAndSettle();

      await tapTreasureCell(tester);
      await tester.tap(find.text('Collecter le trésor'));
      await tester.pumpAndSettle();

      expect(find.text('Ruines fouillées !'), findsOneWidget);
    });

    testWidgets('empty ruins shows empty message when storages full',
        (tester) async {
      final game = Game(
        player: Player(name: 'Nemo'),
        gameMap: buildTestMap(CellContentType.ruins),
        resources: {
          ResourceType.algae: Resource(
              type: ResourceType.algae, amount: 100, maxStorage: 100),
          ResourceType.coral: Resource(
              type: ResourceType.coral, amount: 100, maxStorage: 100),
          ResourceType.ore: Resource(
              type: ResourceType.ore, amount: 100, maxStorage: 100),
          ResourceType.energy: Resource(
              type: ResourceType.energy, amount: 60, maxStorage: 1000),
          ResourceType.pearl: Resource(
              type: ResourceType.pearl, amount: 100, maxStorage: 100),
        },
      );
      await tester.pumpWidget(buildHost(game));
      await tester.pumpAndSettle();

      await tapTreasureCell(tester);
      await tester.tap(find.text('Collecter le trésor'));
      await tester.pumpAndSettle();

      expect(find.text('Ruines fouillées !'), findsOneWidget);
      expect(find.text('Les ruines étaient vides...'), findsOneWidget);
    });
  });
}
