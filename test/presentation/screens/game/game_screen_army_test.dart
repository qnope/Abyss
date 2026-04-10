import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen Army tab', () {
    late FakeGameRepository repository;

    setUp(() {
      mockSvgAssets();
      repository = FakeGameRepository();
    });
    tearDown(() => clearSvgMocks());

    Widget createApp(Game game) => MaterialApp(
          theme: AbyssTheme.create(),
          home: GameScreen(game: game, repository: repository),
        );

    Game armyGame() {
      final buildings = PlayerDefaults.buildings();
      buildings[BuildingType.barracks] =
          Building(type: BuildingType.barracks, level: 1);
      final resources = {
        ResourceType.algae: Resource(type: ResourceType.algae, amount: 500),
        ResourceType.coral: Resource(type: ResourceType.coral, amount: 500),
        ResourceType.ore: Resource(type: ResourceType.ore, amount: 500),
        ResourceType.energy: Resource(type: ResourceType.energy, amount: 500),
        ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 100),
      };
      return Game.singlePlayer(Player(
        name: 'Nemo',
        buildings: buildings,
        resources: resources,
      ));
    }

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

    testWidgets('tapping locked unit shows unlock message', (tester) async {
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
      expect(g.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count, greaterThan(0));
    });
  });
}
