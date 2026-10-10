import 'dart:math';

import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game(Player player, int turn) => Game.singlePlayer(player)..turn = turn;

void main() {
  test('the first turn schedules the first event and draws nothing', () {
    final player = Player(id: 'human', name: 'Nemo');
    final result = TurnResolver().resolve(_game(player, 1), random: Random(3));
    expect(result.event, isNull);
    expect(result.defaultedEvent, isNull);
    expect(player.eventState.nextDrawTurn, inInclusiveRange(5, 8));
  });

  test('the turn result carries the event drawn for the human', () {
    final player = Player(id: 'human', name: 'Nemo')..eventState.schedule(12);
    final result = TurnResolver().resolve(_game(player, 12), random: Random(3));
    expect(result.event, isNotNull);
    expect(result.event, player.eventState.lastDrawn);
  });

  test('the turn result carries the event left without a choice', () {
    final player =
        Player(id: 'human', name: 'Nemo')
          ..eventState.schedule(30)
          ..eventState.setPending(RandomEventType.survivors, 12);
    final result = TurnResolver().resolve(_game(player, 12), random: Random(3));
    expect(result.defaultedEvent, RandomEventType.survivors);
    expect(result.event, isNull);
    expect(
      player.historyEntries.whereType<EventEntry>().single.defaulted,
      isTrue,
    );
  });

  test('the events of a bot stay out of the human turn result', () {
    final human = Player(id: 'human', name: 'Nemo')..eventState.schedule(30);
    final bot = Player(id: 'bot', name: 'Bot')..eventState.schedule(12);
    final game = Game(
      humanPlayerId: human.id,
      players: {human.id: human, bot.id: bot},
    )..turn = 12;
    final result = TurnResolver().resolve(game, random: Random(3));
    expect(result.event, isNull);
    expect(bot.eventState.lastDrawn, isNotNull);
  });
}
