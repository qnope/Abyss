import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/map/game_map_view.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen map tab', () {
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

    Game newGameWithMap({int seed = 42}) {
      final mapResult = MapGenerator.generate(seed: seed);
      final player = Player.withBase(
        name: 'Nemo',
        baseX: mapResult.baseX,
        baseY: mapResult.baseY,
        mapWidth: mapResult.map.width,
        mapHeight: mapResult.map.height,
      );
      return Game.singlePlayer(player)..levels = {1: mapResult.map};
    }

    testWidgets('displays existing map without regeneration',
        (tester) async {
      final game = newGameWithMap(seed: 42);
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.levels[1]!.seed, 42);
      expect(find.byType(GameMapView), findsOneWidget);
      expect(repository.saveCallCount, 0);
    });

    testWidgets('map tab renders GameMapView', (tester) async {
      final game = newGameWithMap();
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(find.byType(GameMapView), findsOneWidget);
    });
  });
}
