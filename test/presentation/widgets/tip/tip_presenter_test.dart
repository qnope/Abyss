import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tip/tip_card.dart';
import 'package:abyss/presentation/widgets/tip/tip_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/objective_helpers.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  late Game game;
  late FakeGameRepository repository;
  late TipPresenter tips;
  ObjectiveState state() => game.humanPlayer.savedObjectiveState!;

  setUp(() {
    mockSvgAssets();
    game = objectiveGame();
    game.humanPlayer.savedObjectiveState = ObjectiveState(tipsEnabled: true);
    game.humanPlayer.raidState.addNoise(NoiseRules.threshold ~/ 4);
    repository = FakeGameRepository();
    tips = TipPresenter(game: game, repository: repository);
  });
  tearDown(clearSvgMocks);

  /// A screen whose buttons open the next tip, right away or after the
  /// frame, and a page pushed on top of it.
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder:
              (context) => Column(
                children: [
                  TextButton(
                    onPressed: () => tips.showNext(context),
                    child: const Text('next'),
                  ),
                  TextButton(
                    onPressed: () {
                      tips.showNext(context);
                      tips.showNext(context);
                    },
                    child: const Text('twice'),
                  ),
                  TextButton(
                    onPressed: () => tips.showAfterAction(context),
                    child: const Text('action'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(body: Text('fight')),
                        ),
                      );
                      tips.showAfterAction(context);
                    },
                    child: const Text('fight'),
                  ),
                ],
              ),
        ),
      ),
    ),
  );

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('opens the first tip that applies and marks it seen', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'next');
    expect(find.text('La jauge de bruit'), findsOneWidget);
    expect(state().seenTips, [TipId.noiseGauge]);
    expect(repository.saveCallCount, 1);
  });

  testWidgets('a tip seen does not open again', (tester) async {
    await pump(tester);
    await tap(tester, 'next');
    await tap(tester, 'Compris');
    await tap(tester, 'next');
    expect(find.byType(TipCard), findsNothing);
    expect(repository.saveCallCount, 1);
  });

  testWidgets('never stacks two tips: the next one waits', (tester) async {
    game.humanPlayer.eventState.recordDraw(RandomEventType.storm);
    await pump(tester);
    await tap(tester, 'twice');
    expect(find.byType(TipCard), findsOneWidget);
    expect(state().seenTips, [TipId.noiseGauge]);

    await tap(tester, 'Compris');
    await tap(tester, 'next');
    expect(find.text('Les événements'), findsOneWidget);
  });

  testWidgets('nothing opens when the tips are off', (tester) async {
    state().tipsEnabled = false;
    await pump(tester);
    await tap(tester, 'next');
    expect(find.byType(TipCard), findsNothing);
    expect(state().seenTips, isEmpty);
    expect(repository.saveCallCount, 0);
  });

  testWidgets('nothing opens once the game is over, unless play goes on', (
    tester,
  ) async {
    game.status = GameStatus.victory;
    await pump(tester);
    await tap(tester, 'next');
    expect(find.byType(TipCard), findsNothing);
    game.status = GameStatus.freePlay;
    await tap(tester, 'next');
    expect(find.text('La jauge de bruit'), findsOneWidget);
  });

  testWidgets('after an action, opens once the frame is drawn', (tester) async {
    await pump(tester);
    await tap(tester, 'action');
    expect(find.text('La jauge de bruit'), findsOneWidget);
  });

  testWidgets('after an action, waits while another page is on top', (
    tester,
  ) async {
    await pump(tester);
    await tap(tester, 'fight');
    expect(find.text('fight'), findsOneWidget);
    expect(find.byType(TipCard), findsNothing);
    expect(state().seenTips, isEmpty);
  });
}
