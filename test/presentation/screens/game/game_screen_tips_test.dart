import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_flow.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/event/event_card.dart';
import 'package:abyss/presentation/widgets/tip/tip_card.dart';
import 'package:abyss/presentation/widgets/tip/tip_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';

Game _game({required bool tips}) => Game.singlePlayer(
  Player(name: 'Nemo')..savedObjectiveState = ObjectiveState(tipsEnabled: tips),
);

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> buildHq(WidgetTester tester, Game game) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: GameScreen(game: game, repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quartier Général'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Construire'));
    await tester.pumpAndSettle();
  }

  testWidgets('the action that fills a quarter of the gauge opens its tip', (
    tester,
  ) async {
    final game = _game(tips: true);
    game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4 - 1);
    await buildHq(tester, game);
    expect(find.byType(TipCard), findsOneWidget);
    expect(find.text('La jauge de bruit'), findsOneWidget);
    expect(game.humanPlayer.savedObjectiveState!.seenTips, [TipId.noiseGauge]);
  });

  testWidgets('no tip opens while the tips are off', (tester) async {
    final game = _game(tips: false);
    await buildHq(tester, game);
    expect(find.byType(TipCard), findsNothing);
    expect(game.humanPlayer.savedObjectiveState!.seenTips, isEmpty);
  });

  testWidgets('at the end of a turn, the tip follows the event card', (
    tester,
  ) async {
    final game = _game(tips: true)..turn = 6;
    game.humanPlayer.eventState.setPending(RandomEventType.caravan, 6);
    final tips = TipPresenter(game: game, repository: repository);
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showTurnOutcome(
                        context,
                        game,
                        repository,
                        const TurnResult(
                          changes: [],
                          previousTurn: 5,
                          newTurn: 6,
                          hadRecruitedUnits: false,
                          event: RandomEventType.caravan,
                        ),
                        () {},
                        tips: tips,
                      ),
                  child: const Text('end'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('end'));
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(EventCard), findsOneWidget);
    expect(find.byType(TipCard), findsNothing);

    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsOneWidget);
    expect(find.text('Les événements'), findsOneWidget);
  });
}
