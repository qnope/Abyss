import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import '../../../helpers/army_taps.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  reduceMotionInEveryTest();
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

    testWidgets('shows the army on its parade ground', (tester) async {
      await goToArmyTab(tester, armyGame());
      expect(find.byType(ArmyView), findsOneWidget);
    });

    testWidgets('tapping unlocked unit shows stats', (tester) async {
      await goToArmyTab(tester, armyGame());
      await tapDrillPad(tester, UnitType.scout);
      await tester.pumpAndSettle();
      expect(find.text('PV: 10'), findsOneWidget);
    });

    testWidgets('tapping locked unit shows unlock message', (tester) async {
      await goToArmyTab(tester, armyGame());
      await tapDrillPad(tester, UnitType.guardian);
      await tester.pumpAndSettle();
      expect(
        find.text('Caserne niveau 3 requise pour débloquer'),
        findsOneWidget,
      );
    });

    testWidgets('recruit units updates count', (tester) async {
      final g = armyGame();
      await goToArmyTab(tester, g);
      await tapDrillPad(tester, UnitType.scout);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recruter'));
      await tester.pumpAndSettle();
      expect(g.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count, greaterThan(0));
    });

    testWidgets('tapping the barracks opens its building sheet',
        (tester) async {
      await goToArmyTab(tester, armyGame());
      await tapBarracks(tester, 1);
      await tester.pumpAndSettle();
      expect(find.text('Améliorer'), findsOneWidget);
    });

    testWidgets('the army counts every place and marks what can be recruited',
        (tester) async {
      final g = armyGame();
      g.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count = 3;
      g.humanPlayer.recruitedUnitTypes.add(UnitType.harpoonist);
      await goToArmyTab(tester, g);
      final army = tester.widget<ArmyView>(find.byType(ArmyView));
      expect(army.counts[UnitType.scout], 3);
      expect(army.recruitable, {UnitType.scout});
    });

    testWidgets('a squad\'s sheet counts the units of the place shown',
        (tester) async {
      final g = armyGame();
      g.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count = 3;
      g.humanPlayer.unitsPerLevel[2] = {
        UnitType.scout: Unit(type: UnitType.scout, count: 5),
      };
      await goToArmyTab(tester, g);
      await tapDrillPad(tester, UnitType.scout);
      await tester.pumpAndSettle();
      expect(find.text('En service : 8'), findsOneWidget);
      await tester.tapAt(const Offset(400, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Niv. 2'));
      await tester.pumpAndSettle();
      await tapDrillPad(tester, UnitType.scout);
      await tester.pumpAndSettle();
      expect(find.text('En service : 5'), findsOneWidget);
    });
  });
}
