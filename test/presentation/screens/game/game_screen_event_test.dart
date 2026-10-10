import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_flow.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/event/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

/// Game of turn 3 whose 4 survivors wait for a choice.
Game _survivorsGame() {
  final player = Player(name: 'Nemo')..eventState.schedule(100);
  player.eventState
    ..setPending(RandomEventType.survivors, 3)
    ..survivors = 4;
  return Game.singlePlayer(player)..turn = 3;
}

int _harpoonists(Game game) =>
    game.humanPlayer.unitsOnLevel(1)[UnitType.harpoonist]!.count;

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  testWidgets('the card opens after the turn summary and settles the choice',
      (tester) async {
    final game = _survivorsGame();
    var changed = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTurnOutcome(
              context,
              game,
              repository,
              const TurnResult(
                changes: [],
                previousTurn: 2,
                newTurn: 3,
                hadRecruitedUnits: false,
                event: RandomEventType.survivors,
              ),
              () => changed++,
            ),
            child: const Text('end'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('end'));
    await tester.pumpAndSettle();
    expect(find.text('Événement : Survivants'), findsOneWidget);
    expect(find.byType(EventCard), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(EventCard), findsOneWidget);

    final before = _harpoonists(game);
    await tester.tap(find.text('Accueillir 4 Harponneurs'));
    await tester.pumpAndSettle();
    expect(find.byType(EventCard), findsNothing);
    expect(_harpoonists(game), before + 4);
    expect(game.humanPlayer.eventState.hasPending, isFalse);
    expect(repository.saveCallCount, 1);
    expect(changed, 1);
    expect(
      find.text('Survivants : Accueillir 4 Harponneurs'),
      findsOneWidget,
    );
  });

  testWidgets('the banner reopens the card of the pending event', (
    tester,
  ) async {
    final game = _survivorsGame();
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: GameScreen(game: game, repository: repository),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Événement : Survivants — choisir'));
    await tester.pumpAndSettle();
    expect(find.byType(EventCard), findsOneWidget);

    await tester.tap(find.text('Refuser'));
    await tester.pumpAndSettle();
    expect(game.humanPlayer.eventState.hasPending, isFalse);
    expect(find.text('Événement : Survivants — choisir'), findsNothing);
  });

  testWidgets('ending the turn of a draw opens the event card', (
    tester,
  ) async {
    final game = Game.singlePlayer(Player(name: 'Nemo'));
    game.humanPlayer.eventState.schedule(1);
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: GameScreen(game: game, repository: repository),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tour suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(EventCard), findsOneWidget);
  });

  testWidgets('ending a turn with a pending choice warns of it', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: GameScreen(game: _survivorsGame(), repository: repository),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tour suivant'));
    await tester.pumpAndSettle();
    expect(
      find.text("Survivants : sans choix, l'option prudente s'appliquera"),
      findsOneWidget,
    );
  });
}
