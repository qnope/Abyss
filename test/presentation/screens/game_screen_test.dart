import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/presentation/screens/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../helpers/fake_game_repository.dart';
import '../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen', () {
    late Game game;
    late FakeGameRepository repository;

    setUp(() {
      mockSvgAssets();
      game = Game(player: Player(name: 'Nemo'));
      repository = FakeGameRepository();
    });

    tearDown(() => clearSvgMocks());

    Widget createApp() {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: repository),
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

      // Initially on Base tab
      expect(find.text('Base'), findsWidgets);

      // Tap Carte tab
      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      // Now Carte placeholder is visible
      expect(find.text('Carte'), findsWidgets);
    });

    testWidgets('next turn increments turn number', (tester) async {
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      expect(find.text('Tour 1'), findsOneWidget);

      await tester.tap(find.text('Tour suivant'));
      await tester.pump();

      expect(find.text('Tour 2'), findsOneWidget);
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

      // Open the detail sheet
      await tester.tap(find.text('Quartier Général'));
      await tester.pumpAndSettle();

      // Tap Construire (level 0 → 1)
      await tester.tap(find.text('Construire'));
      await tester.pumpAndSettle();

      // Sheet closed, verify level changed
      expect(find.text('Niveau 1'), findsOneWidget);
    });
  });
}
