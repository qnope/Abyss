import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/game_screen_event_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a choice made after its turn is refused and tells why', (
    tester,
  ) async {
    final player = Player(name: 'Nemo')..eventState.schedule(100);
    player.eventState
      ..setPending(RandomEventType.survivors, 3)
      ..survivors = 4;
    final game = Game.singlePlayer(player)..turn = 4;
    final repository = FakeGameRepository();
    var changes = 0;
    await tester.pumpWidget(localizedApp(
      locale: AbyssLocale.en,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => openEventCard(context, game, repository,
                RandomEventType.survivors, () => changes++),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.eventCardRefuse));
    await tester.pumpAndSettle();

    expect(find.text(en.actionFailureNotThisChoiceTurn), findsOneWidget);
    expect(game.humanPlayer.eventState.hasPending, isTrue);
    expect(repository.saveCallCount, 0);
    expect(changes, 1);
  });
}
