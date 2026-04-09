import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  group('GameScreen end-turn history integration', () {
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

    Game buildGame() {
      final b = PlayerDefaults.buildings();
      b[BuildingType.algaeFarm] =
          Building(type: BuildingType.algaeFarm, level: 1);
      final r = PlayerDefaults.resources();
      r[ResourceType.algae] =
          Resource(type: ResourceType.algae, amount: 100);
      return Game.singlePlayer(
        Player(name: 'Nemo', buildings: b, resources: r),
      );
    }

    testWidgets('confirming next turn records a TurnEndEntry',
        (tester) async {
      final game = buildGame();
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      final initialTurn = game.turn;

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(game.turn, initialTurn + 1);
      expect(game.humanPlayer.historyEntries, isNotEmpty);
      final last = game.humanPlayer.historyEntries.last;
      expect(last, isA<TurnEndEntry>());
      expect((last as TurnEndEntry).turn, initialTurn);
    });

    testWidgets('cancelling next turn does not record history',
        (tester) async {
      final game = buildGame();
      await tester.pumpWidget(createApp(game));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(game.humanPlayer.historyEntries, isEmpty);
    });
  });
}
