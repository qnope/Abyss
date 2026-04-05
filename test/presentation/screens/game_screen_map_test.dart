import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/map_generator.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/presentation/screens/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/game_map_view.dart';
import '../../helpers/fake_game_repository.dart';
import '../../helpers/test_svg_helper.dart';

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

    testWidgets('generates map when gameMap is null', (tester) async {
      final game = Game(player: Player(name: 'Nemo'));
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.gameMap, isNotNull);
      expect(find.byType(GameMapView), findsOneWidget);
    });

    testWidgets('displays existing map without regeneration',
        (tester) async {
      final map = MapGenerator.generate(seed: 42);
      final game = Game(player: Player(name: 'Nemo'), gameMap: map);
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(game.gameMap!.seed, 42);
      expect(find.byType(GameMapView), findsOneWidget);
      expect(repository.saveCallCount, 0);
    });

    testWidgets('saves game after generating map', (tester) async {
      final game = Game(player: Player(name: 'Nemo'));
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();

      expect(repository.saveCallCount, 1);
    });
  });
}
