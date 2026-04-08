import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
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
      return Game.singlePlayer(player)..gameMap = gen.map;
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
