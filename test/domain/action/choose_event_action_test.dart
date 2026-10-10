import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/replay/replay_journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event/event_test_helper.dart';

void main() {
  test('is a French choice of the event action type', () {
    expect(ChooseEventAction(accept: true).type, ActionType.chooseEvent);
    expect(ChooseEventAction(accept: true).description, "Accepter l'événement");
    expect(ChooseEventAction(accept: false).description, "Refuser l'événement");
  });

  test('fails when no event waits for a choice', () {
    final player = eventPlayer();
    final result = ChooseEventAction(
      accept: true,
    ).validate(eventGame(player, turn: 12), player);
    expect(result.isSuccess, isFalse);
    expect(result.reason, 'Aucun événement en attente');
  });

  test('fails outside the turn of the choice', () {
    final player =
        eventPlayer()..eventState.setPending(RandomEventType.caravan, 13);
    final result = ChooseEventAction(
      accept: true,
    ).validate(eventGame(player, turn: 12), player);
    expect(result.isSuccess, isFalse);
    expect(result.reason, "Ce n'est pas le tour de ce choix");
  });

  for (final accept in [true, false]) {
    test('settles the event once chosen (accept: $accept)', () {
      final player =
          eventPlayer()..eventState.setPending(RandomEventType.caravan, 12);
      final game = eventGame(player, turn: 12);

      final result = ActionExecutor().execute(
        ChooseEventAction(accept: accept),
        game,
        player,
      );

      expect(result.isSuccess, isTrue);
      expect(player.eventState.hasPending, isFalse);
      expect(player.eventState.lastDrawn, RandomEventType.caravan);
      final entry = eventEntriesOf(player).single;
      expect(entry.turn, 12);
      expect(entry.type, RandomEventType.caravan);
      expect(entry.accepted, accept);
      expect(entry.defaulted, isFalse);
    });
  }

  test('the choice is written in the replay journal', () {
    final player =
        eventPlayer()..eventState.setPending(RandomEventType.wreck, 12);
    final game = eventGame(player, turn: 12)
      ..replay = ReplayJournal(mapSeed: 1, playerName: 'Test');

    ActionExecutor().execute(ChooseEventAction(accept: false), game, player);

    expect(game.replay!.actionsOf(12), [
      {'do': 'event', 'accept': false},
    ]);
    expect(game.replay!.exact, isTrue);
  });

  test('a second choice in the same turn fails', () {
    final player =
        eventPlayer()..eventState.setPending(RandomEventType.wreck, 12);
    final game = eventGame(player, turn: 12);
    final executor = ActionExecutor();
    executor.execute(ChooseEventAction(accept: true), game, player);
    final again = executor.execute(
      ChooseEventAction(accept: true),
      game,
      player,
    );
    expect(again.isSuccess, isFalse);
    expect(eventEntriesOf(player), hasLength(1));
  });
}
