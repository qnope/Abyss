import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

const _lastChance = 'Si ce raid est perdu, la partie est terminée.';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Game gameWithRaidDue({required int lostInARow}) {
    final player = Player(name: 'Nemo');
    player.raidState
      ..lostInARow = lostInARow
      ..announce(
        const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5),
        12,
      );
    return Game.singlePlayer(player)..turn = 12;
  }

  Future<void> endTurn(WidgetTester tester, Game game) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: GameScreen(game: game, repository: FakeGameRepository()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tour suivant'));
    await tester.pumpAndSettle();
  }

  testWidgets('warns before the raid that can end the game', (tester) async {
    await endTurn(tester, gameWithRaidDue(lostInARow: 2));
    expect(find.text(_lastChance), findsOneWidget);
  });

  testWidgets('no last chance warning after a single lost raid',
      (tester) async {
    await endTurn(tester, gameWithRaidDue(lostInARow: 1));
    expect(find.text(_lastChance), findsNothing);
  });

  testWidgets('losing the third raid opens the defeat screen',
      (tester) async {
    final game = gameWithRaidDue(lostInARow: 2);
    await endTurn(tester, game);
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Raid sur la base'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Retour à la base'), 300);
    await tester.tap(find.text('Retour à la base'));
    await tester.pumpAndSettle();

    expect(game.status, GameStatus.defeat);
    expect(find.text('DÉFAITE'), findsOneWidget);
    expect(find.text('Tour suivant'), findsNothing);
  });
}
