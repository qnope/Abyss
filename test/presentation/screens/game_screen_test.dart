import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit_type.dart';
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

      // Confirmation dialog appears
      expect(find.text('Passer au tour suivant ?'), findsOneWidget);
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // Summary dialog appears — dismiss it
      expect(find.text('Resume du tour'), findsOneWidget);
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

    group('Turn flow', () {
      testWidgets('tapping Tour suivant shows confirmation dialog',
          (tester) async {
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();

        expect(find.text('Passer au tour suivant ?'), findsOneWidget);
      });

      testWidgets('cancel keeps same turn', (tester) async {
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(find.text('Tour 1'), findsOneWidget);
      });

      testWidgets('resources increase after turn', (tester) async {
        final customGame = Game(
          player: Player(name: 'Nemo'),
          buildings: {
            ...Game.defaultBuildings(),
            BuildingType.algaeFarm: Building(
              type: BuildingType.algaeFarm,
              level: 1,
            ),
          },
        );
        await tester.pumpWidget(createApp(customGame));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();

        // Summary shows +50 algae
        expect(find.text('+50'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Algae went from 100 to 150
        expect(customGame.resources[ResourceType.algae]!.amount, 150);
      });

      testWidgets('resource capped at maxStorage', (tester) async {
        final customGame = Game(
          player: Player(name: 'Nemo'),
          buildings: {
            ...Game.defaultBuildings(),
            BuildingType.algaeFarm: Building(
              type: BuildingType.algaeFarm,
              level: 1,
            ),
          },
          resources: {
            ...Game.defaultResources(),
            ResourceType.algae: Resource(
              type: ResourceType.algae,
              amount: 498,
              maxStorage: 500,
            ),
          },
        );
        await tester.pumpWidget(createApp(customGame));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(customGame.resources[ResourceType.algae]!.amount, 500);
      });

      testWidgets('game is saved after turn', (tester) async {
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(repository.saveCallCount, 1);
      });

      testWidgets('summary dialog appears after confirming',
          (tester) async {
        await tester.pumpWidget(createApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();

        expect(find.text('Resume du tour'), findsOneWidget);
      });
    });

    group('Army tab', () {
      Game armyGame() => Game(
            player: Player(name: 'Nemo'),
            buildings: {
              ...Game.defaultBuildings(),
              BuildingType.barracks:
                  Building(type: BuildingType.barracks, level: 1),
            },
            resources: {
              ResourceType.algae:
                  Resource(type: ResourceType.algae, amount: 500),
              ResourceType.coral:
                  Resource(type: ResourceType.coral, amount: 500),
              ResourceType.ore:
                  Resource(type: ResourceType.ore, amount: 500),
              ResourceType.energy:
                  Resource(type: ResourceType.energy, amount: 500),
              ResourceType.pearl:
                  Resource(type: ResourceType.pearl, amount: 100),
            },
          );

      Future<void> goToArmyTab(WidgetTester tester, Game g) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());
        addTearDown(() => tester.view.resetDevicePixelRatio());
        await tester.pumpWidget(createApp(g));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Armée'));
        await tester.pumpAndSettle();
      }

      testWidgets('shows unit cards', (tester) async {
        await goToArmyTab(tester, armyGame());
        expect(find.text('Eclaireur'), findsOneWidget);
        expect(find.text('Harponneur'), findsOneWidget);
      });

      testWidgets('locked units shown', (tester) async {
        await goToArmyTab(tester, armyGame());
        expect(find.text('Verrouille'), findsNWidgets(4));
      });

      testWidgets('tapping unlocked unit shows stats', (tester) async {
        await goToArmyTab(tester, armyGame());
        await tester.tap(find.text('Eclaireur'));
        await tester.pumpAndSettle();
        expect(find.text('PV: 10'), findsOneWidget);
      });

      testWidgets('tapping locked unit shows unlock message',
          (tester) async {
        await goToArmyTab(tester, armyGame());
        await tester.tap(find.text('Gardien'));
        await tester.pumpAndSettle();
        expect(
          find.text('Caserne niveau 3 requise pour debloquer'),
          findsOneWidget,
        );
      });

      testWidgets('recruit units updates count', (tester) async {
        final g = armyGame();
        await goToArmyTab(tester, g);
        await tester.tap(find.text('Eclaireur'));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(Slider), const Offset(200, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Recruter'));
        await tester.pumpAndSettle();
        expect(g.units[UnitType.scout]!.count, greaterThan(0));
      });
    });
  });
}
