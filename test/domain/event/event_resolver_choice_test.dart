import 'dart:math';

import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_test_helper.dart';

void main() {
  test('the prudent option applies when the player did not choose', () {
    final player =
        eventPlayer()
          ..eventState.schedule(30)
          ..eventState.setPending(RandomEventType.caravan, 12);
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(outcome.defaulted, RandomEventType.caravan);
    expect(player.eventState.hasPending, isFalse);
    final entry = eventEntriesOf(player).single;
    expect(entry.turn, 12);
    expect(entry.type, RandomEventType.caravan);
    expect(entry.accepted, isFalse);
    expect(entry.defaulted, isTrue);
  });

  test('an event waiting for a later turn is left to the player', () {
    final player =
        eventPlayer()
          ..eventState.schedule(30)
          ..eventState.setPending(RandomEventType.caravan, 13);
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(outcome.defaulted, isNull);
    expect(player.eventState.pending, RandomEventType.caravan);
    expect(eventEntriesOf(player), isEmpty);
  });

  test('an event without a choice applies at the draw, never pending', () {
    var storms = 0;
    for (var seed = 0; seed < 100; seed++) {
      final player = eventPlayer()..eventState.schedule(12);
      final outcome = EventResolver.resolve(
        eventGame(player, turn: 12),
        player,
        12,
        random: Random(seed),
      );
      if (outcome.drawn != RandomEventType.storm) continue;
      storms++;
      expect(player.eventState.hasPending, isFalse);
      expect(player.eventState.lastDrawn, RandomEventType.storm);
      expect(player.eventState.eventsSeen, 1);
      final entry = eventEntriesOf(player).single;
      expect(entry.type, RandomEventType.storm);
      expect(entry.defaulted, isFalse);
    }
    expect(storms, greaterThan(0));
  });

  test('no predators when a raid hits at the end of the next turn', () {
    for (var seed = 0; seed < 200; seed++) {
      final player = eventPlayer()..eventState.schedule(20);
      player.raidState.announce(
        const MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3),
        21,
      );
      final outcome = EventResolver.resolve(
        eventGame(player, turn: 20),
        player,
        20,
        random: Random(seed),
      );
      expect(outcome.drawn, isNot(RandomEventType.predators));
    }
  });

  test('the same seed draws the same events', () {
    List<Object?> play() {
      final player = eventPlayer();
      final game = eventGame(player);
      final random = Random(42);
      return [
        for (var turn = 1; turn <= 80; turn++)
          ...() {
            final o = EventResolver.resolve(game, player, turn, random: random);
            return [o.drawn, o.defaulted];
          }(),
        player.eventState.nextDrawTurn,
        player.eventState.eventsSeen,
      ];
    }

    final first = play();
    expect(play(), first);
    expect(first.whereType<RandomEventType>(), isNotEmpty);
  });
}
