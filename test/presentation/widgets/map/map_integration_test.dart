import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

Game _buildGame({int seed = 42}) {
  final generation = MapGenerator.generate(seed: seed);
  final player = Player.withBase(
    name: 'Nemo',
    baseX: generation.baseX,
    baseY: generation.baseY,
    mapWidth: generation.map.width,
    mapHeight: generation.map.height,
  );
  return Game.singlePlayer(player)..gameMap = generation.map;
}

void main() {
  group('Map integration', () {
    late FakeGameRepository repository;

    setUp(() => mockSvgAssets());
    tearDown(() => clearSvgMocks());

    Widget createApp(Game game) {
      repository = FakeGameRepository();
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: repository),
      );
    }

    testWidgets('tab opens and shows pre-generated map', (tester) async {
      final game = _buildGame();
      expect(game.gameMap, isNotNull);

      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.gameMap!.cells.length, 400);
      expect(find.byType(GameMapView), findsOneWidget);
    });

    testWidgets('existing map loads without regeneration',
        (tester) async {
      final game = _buildGame(seed: 42);

      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.gameMap!.seed, 42);
      expect(repository.saveCallCount, 0);
      expect(find.byType(GameMapView), findsOneWidget);
    });

    testWidgets('map dimensions match generator output', (tester) async {
      final game = _buildGame();

      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.gameMap!.width, 20);
      expect(game.gameMap!.height, 20);
      expect(repository.saveCallCount, 0);
    });
  });
}
