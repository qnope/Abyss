import 'dart:math';

import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_test_helper.dart';

void main() {
  test('a cold current left without a choice starts with the next turn', () {
    final player =
        eventPlayer()
          ..eventState.schedule(100)
          ..eventState.setPending(RandomEventType.coldCurrent, 12);
    EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    final state = player.eventState;
    expect(state.active, RandomEventType.coldCurrent);
    expect(state.isActive(RandomEventType.coldCurrent, 13), isTrue);
    expect(state.activeUntilTurn, 12 + EventRules.effectTurns);
    expect(state.heating, isFalse);
  });

  test('a warm current makes noise up to its last turn, then ends', () {
    final player = eventPlayer()..eventState.schedule(100);
    player.eventState.activate(RandomEventType.warmCurrent, untilTurn: 14);
    final game = eventGame(player, turn: 12);
    final noise = <int>[
      for (var turn = 12; turn <= 16; turn++)
        () {
          final before = player.raidState.totalNoise;
          EventResolver.resolve(game, player, turn, random: Random(1));
          return player.raidState.totalNoise - before;
        }(),
    ];
    expect(noise, [3, 3, 3, 0, 0]);
    expect(player.eventState.active, isNull);
  });
}
