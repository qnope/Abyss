import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen', () {
    late Game game;
    late FakeGameRepository repository;

    Game makeGame() {
      final gen = MapGenerator.generate(seed: 1);
      final player = Player.withBase(
        name: 'Nemo',
        baseX: gen.baseX,
        baseY: gen.baseY,
        mapWidth: gen.map.width,
        mapHeight: gen.map.height,
      );
      return Game.singlePlayer(player)..levels = {1: gen.map};
    }

    setUp(() {
      mockSvgAssets();
      game = makeGame();
      repository = FakeGameRepository();
    });

    tearDown(() => clearSvgMocks());

    Widget createApp([Game? customGame]) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(
          game: customGame ?? game,
          repository: repository,
        ),
      );
    }

    testWidgets('renders bottom bar with tab labels', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Base'), findsWidgets);
      expect(find.text('Carte'), findsOneWidget);
      expect(find.text('Tech'), findsOneWidget);
    });

    testWidgets('tab switching changes content', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Base'), findsWidgets);

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(find.text('Carte'), findsWidgets);
    });

    testWidgets('next turn increments turn number', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Tour 1'), findsOneWidget);

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 1 \u2192 Tour 2'), findsOneWidget);
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 1 \u2192 Tour 2'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 2'), findsOneWidget);
    });

    testWidgets('Tech tab shows tech tree instead of placeholder',
        (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tech'));
      await tester.pumpAndSettle();

      expect(find.text('Bientôt disponible'), findsNothing);
    });

    testWidgets('Base tab shows building list', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Quartier Général'), findsOneWidget);
    });

    testWidgets('tapping building card opens detail sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quartier Général'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Centre de commandement'),
        findsOneWidget,
      );
    });

    testWidgets('tapping monster lair opens sheet then ArmySelectionScreen',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      const int lairX = 11;
      const int lairY = 10;
      const int mapSize = 20;
      final cells = List.generate(
        mapSize * mapSize,
        (_) => MapCell(terrain: TerrainType.plain),
      );
      cells[lairY * mapSize + lairX] = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
        lair: const MonsterLair(
          difficulty: MonsterDifficulty.easy,
          unitCount: 2,
        ),
      );
      final lairMap = GameMap(
        width: mapSize,
        height: mapSize,
        cells: cells,
        seed: 1,
      );
      final lairGame = Game.singlePlayer(Player(
        name: 'Nemo',
        baseX: 10,
        baseY: 10,
        revealedCellsPerLevel: {1: [
          for (var y = 0; y < mapSize; y++)
            for (var x = 0; x < mapSize; x++) GridPosition(x: x, y: y),
        ]},
      ))
        ..levels = {1: lairMap};
      lairGame.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count = 3;

      await tester.pumpWidget(createApp(lairGame));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      final view = tester.widget<GameMapView>(find.byType(GameMapView));
      view.onCellTap!(lairX, lairY);
      await tester.pumpAndSettle();

      expect(find.text('Préparer le combat'), findsOneWidget);

      await tester.tap(find.text('Préparer le combat'));
      await tester.pumpAndSettle();

      expect(find.byType(ArmySelectionScreen), findsOneWidget);
    });

    testWidgets('upgrade increases building level', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quartier Général'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Construire'));
      await tester.pumpAndSettle();

      expect(find.text('Niveau 1'), findsOneWidget);
    });
  });
}
