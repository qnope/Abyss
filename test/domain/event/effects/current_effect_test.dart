import 'package:abyss/domain/event/effects/current_effect.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event_test_helper.dart';

const _warm = CurrentEffect(RandomEventType.warmCurrent);
const _cold = CurrentEffect(RandomEventType.coldCurrent);

void main() {
  test('exploiting a warm current lasts through the 3 turns from now', () {
    final player = eventPlayer();
    _warm.apply(eventGame(player, turn: 12), player, accept: true, turn: 12);
    final state = player.eventState;
    expect(state.active, RandomEventType.warmCurrent);
    expect(state.activeUntilTurn, 12 + EventRules.effectTurns - 1);
    expect(state.heating, isFalse);
  });

  test('letting a warm current pass changes nothing', () {
    final player = eventPlayer();
    _warm.apply(eventGame(player, turn: 12), player, accept: false, turn: 12);
    expect(player.eventState.active, isNull);
  });

  test('heating the farms lasts 3 turns and spends energy', () {
    final player = eventPlayer();
    _cold.apply(eventGame(player, turn: 12), player, accept: true, turn: 12);
    final state = player.eventState;
    expect(state.active, RandomEventType.coldCurrent);
    expect(state.activeUntilTurn, 14);
    expect(state.heating, isTrue);
  });

  test('enduring a cold current lasts 3 turns without heating', () {
    final player = eventPlayer();
    _cold.apply(eventGame(player, turn: 12), player, accept: false, turn: 12);
    final state = player.eventState;
    expect(state.active, RandomEventType.coldCurrent);
    expect(state.activeUntilTurn, 14);
    expect(state.heating, isFalse);
  });

  test('a warm current makes noise at the end of each of its turns', () {
    final player = eventPlayer();
    _warm.onTurnEnd(eventGame(player, turn: 12), player, turn: 12);
    expect(player.raidState.totalNoise, EventRules.warmNoisePerTurn);
  });

  test('a cold current makes no noise', () {
    final player = eventPlayer();
    _cold.onTurnEnd(eventGame(player, turn: 12), player, turn: 12);
    expect(player.raidState.totalNoise, 0);
  });
}
