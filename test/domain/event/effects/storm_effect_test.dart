import 'package:abyss/domain/event/effects/storm_effect.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event_test_helper.dart';

const _storm = StormEffect();

void main() {
  test('a storm drawn at the end of turn 12 lasts through turns 13 and 14', () {
    final player = eventPlayer();
    _storm.apply(eventGame(player, turn: 12), player, accept: true, turn: 13);
    final state = player.eventState;
    expect(state.active, RandomEventType.storm);
    expect(state.activeUntilTurn, 13 + EventRules.stormTurns - 1);
    expect(state.isActive(RandomEventType.storm, 14), isTrue);
    expect(state.isActive(RandomEventType.storm, 15), isFalse);
  });

  test('a storm takes 10 points off the gauge, not off the total', () {
    final player = eventPlayer()..raidState.addNoise(25);
    _storm.apply(eventGame(player, turn: 12), player, accept: true, turn: 13);
    expect(player.raidState.noise, 25 - EventRules.stormNoiseRelief);
    expect(player.raidState.totalNoise, 25);
  });

  test('a storm never takes the gauge below zero', () {
    final player = eventPlayer()..raidState.addNoise(6);
    _storm.apply(eventGame(player, turn: 12), player, accept: true, turn: 13);
    expect(player.raidState.noise, 0);
    expect(player.raidState.totalNoise, 6);
  });
}
