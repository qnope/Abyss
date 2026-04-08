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
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen consumption', () {
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

    Game buildGame({
      Map<BuildingType, Building>? buildings,
      Map<ResourceType, Resource>? resources,
      Map<UnitType, Unit>? units,
    }) {
      final b = PlayerDefaults.buildings();
      if (buildings != null) b.addAll(buildings);
      final r = PlayerDefaults.resources();
      if (resources != null) r.addAll(resources);
      final u = PlayerDefaults.units();
      if (units != null) u.addAll(units);
      return Game.singlePlayer(
        Player(name: 'Nemo', buildings: b, resources: r, units: u),
      );
    }

    group('consumption display', () {
      testWidgets('resource bar shows energy consumption', (tester) async {
        final game = buildGame(buildings: {
          BuildingType.headquarters:
              Building(type: BuildingType.headquarters, level: 1),
          BuildingType.solarPanel:
              Building(type: BuildingType.solarPanel, level: 1),
        });
        await tester.pumpWidget(createApp(game));
        await tester.pumpAndSettle();

        expect(find.textContaining('/-4/t'), findsOneWidget);
      });

      testWidgets('resource bar shows algae consumption', (tester) async {
        final game = buildGame(units: {
          UnitType.scout: Unit(type: UnitType.scout, count: 10),
        });
        await tester.pumpWidget(createApp(game));
        await tester.pumpAndSettle();

        expect(find.textContaining('/-10/t'), findsOneWidget);
      });
    });

    group('turn with consumption', () {
      testWidgets('turn confirmation shows deactivation warning',
          (tester) async {
        final game = buildGame(
          buildings: {
            BuildingType.headquarters:
                Building(type: BuildingType.headquarters, level: 1),
            BuildingType.algaeFarm:
                Building(type: BuildingType.algaeFarm, level: 1),
            BuildingType.coralMine:
                Building(type: BuildingType.coralMine, level: 1),
            BuildingType.oreExtractor:
                Building(type: BuildingType.oreExtractor, level: 1),
          },
          resources: {
            ResourceType.energy: Resource(
                type: ResourceType.energy, amount: 5, maxStorage: 1000),
          },
        );
        await tester.pumpWidget(createApp(game));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();

        expect(find.text('Batiments desactives'), findsOneWidget);
      });

      testWidgets('turn summary shows consumption results', (tester) async {
        final game = buildGame(buildings: {
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 1),
          BuildingType.solarPanel:
              Building(type: BuildingType.solarPanel, level: 1),
        });
        await tester.pumpWidget(createApp(game));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tour suivant'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmer'));
        await tester.pumpAndSettle();

        expect(find.textContaining('/-'), findsWidgets);
      });
    });
  });
}
