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
  group('GameScreen turn flow', () {
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

    testWidgets('tapping Tour suivant shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(createApp(buildGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 1 \u2192 Tour 2'), findsOneWidget);
    });

    testWidgets('cancel keeps same turn', (tester) async {
      await tester.pumpWidget(createApp(buildGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 1'), findsOneWidget);
    });

    testWidgets('resources increase after turn', (tester) async {
      final game = buildGame(buildings: {
        BuildingType.algaeFarm:
            Building(type: BuildingType.algaeFarm, level: 1),
      });
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(find.text('+50'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(game.humanPlayer.resources[ResourceType.algae]!.amount, 150);
    });

    testWidgets('resource capped at maxStorage', (tester) async {
      final game = buildGame(
        buildings: {
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 1),
        },
        resources: {
          ResourceType.algae: Resource(
              type: ResourceType.algae, amount: 498, maxStorage: 500),
        },
      );
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(game.humanPlayer.resources[ResourceType.algae]!.amount, 500);
    });

    testWidgets('game is saved after turn', (tester) async {
      await tester.pumpWidget(createApp(buildGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(repository.saveCallCount, 1);
    });

    testWidgets('summary dialog appears after confirming', (tester) async {
      await tester.pumpWidget(createApp(buildGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(find.text('Tour 1 \u2192 Tour 2'), findsOneWidget);
    });
  });
}
