import 'dart:math';

import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/random_event_choice.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_test_helper.dart';

void main() {
  test('a new game schedules its first draw on turns 5 to 8', () {
    final turns = <int>{};
    for (var seed = 0; seed < 100; seed++) {
      final player = eventPlayer();
      final outcome = EventResolver.resolve(
        eventGame(player),
        player,
        1,
        random: Random(seed),
      );
      expect(outcome.drawn, isNull);
      expect(player.eventState.hasPending, isFalse);
      turns.add(player.eventState.nextDrawTurn!);
    }
    expect(turns, {5, 6, 7, 8});
  });

  test('nothing is drawn before the scheduled turn', () {
    final player = eventPlayer()..eventState.schedule(10);
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 9),
      player,
      9,
      random: Random(1),
    );
    expect(outcome.drawn, isNull);
    expect(player.eventState.nextDrawTurn, 10);
    expect(player.eventState.eventsSeen, 0);
  });

  test('a draw waits for a choice next turn, the next one 5 to 8 later', () {
    final nextTurns = <int>{};
    for (var seed = 0; seed < 100; seed++) {
      final player = eventPlayer()..eventState.schedule(12);
      final outcome = EventResolver.resolve(
        eventGame(player, turn: 12),
        player,
        12,
        random: Random(seed),
      );
      final drawn = outcome.drawn!;
      final state = player.eventState;
      expect(state.lastDrawn, drawn);
      expect(state.eventsSeen, 1);
      if (drawn.hasChoice) {
        expect(state.pending, drawn);
        expect(state.pendingTurn, 13);
      }
      nextTurns.add(state.nextDrawTurn!);
    }
    expect(nextTurns, {17, 18, 19, 20});
  });

  test('an event still waiting for a choice postpones the draw', () {
    final player =
        eventPlayer()
          ..eventState.schedule(12)
          ..eventState.setPending(RandomEventType.caravan, 13);
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(outcome.drawn, isNull);
    expect(player.eventState.pending, RandomEventType.caravan);
    expect(player.eventState.nextDrawTurn, 13);
  });

  test('a lasting effect postpones the draw until it ends', () {
    final player =
        eventPlayer()
          ..eventState.schedule(12)
          ..eventState.activate(RandomEventType.warmCurrent, untilTurn: 14);
    final game = eventGame(player, turn: 12);
    final random = Random(1);
    for (final turn in [12, 13]) {
      final outcome = EventResolver.resolve(game, player, turn, random: random);
      expect(outcome.drawn, isNull);
      expect(player.eventState.nextDrawTurn, turn + 1);
    }
    final outcome = EventResolver.resolve(game, player, 14, random: random);
    expect(player.eventState.active, isNull);
    expect(outcome.drawn, isNotNull);
  });

  test('a lasting effect ends once its last turn is over', () {
    final player =
        eventPlayer()
          ..eventState.schedule(30)
          ..eventState.activate(RandomEventType.storm, untilTurn: 9);
    final game = eventGame(player, turn: 8);
    EventResolver.resolve(game, player, 8, random: Random(1));
    expect(player.eventState.active, RandomEventType.storm);
    EventResolver.resolve(game, player, 9, random: Random(1));
    expect(player.eventState.active, isNull);
  });
}
