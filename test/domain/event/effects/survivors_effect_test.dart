import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/effects/survivors_effect.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event_test_helper.dart';

const _survivors = SurvivorsEffect();

int _harpoonists(Player player) =>
    player.unitsOnLevel(1)[UnitType.harpoonist]!.count;

Map<ResourceType, int> _stocks(Player player) => {
  for (final e in player.resources.entries) e.key: e.value.amount,
};

/// Player whose survivors, drawn at the end of turn 11, wait on turn 12.
Player _met(int count) {
  final player = eventPlayer()..eventState.schedule(100);
  player.eventState
    ..setPending(RandomEventType.survivors, 12)
    ..survivors = count;
  return player;
}

void main() {
  test('3 survivors early on, one more every 20 turns, 8 at most', () {
    expect(SurvivorsEffect.countAt(5), 3);
    expect(SurvivorsEffect.countAt(19), 3);
    expect(SurvivorsEffect.countAt(20), 4);
    expect(SurvivorsEffect.countAt(45), 5);
    expect(SurvivorsEffect.countAt(100), 8);
    expect(SurvivorsEffect.countAt(400), 8);
  });

  test('the draw remembers how many survivors are met', () {
    final player = eventPlayer();
    _survivors.onDraw(
      eventGame(player, turn: 20),
      player,
      turn: 20,
      random: Random(1),
    );
    expect(player.eventState.survivors, 4);
  });

  test('welcoming them adds free harpoonists on level 1, silently', () {
    final player = _met(4);
    final before = _stocks(player);
    final result = ActionExecutor().execute(
      ChooseEventAction(accept: true),
      eventGame(player, turn: 12),
      player,
    );
    expect(result.isSuccess, isTrue);
    expect(_harpoonists(player), 4);
    expect(_stocks(player), before);
    expect(player.raidState.totalNoise, 0);
    expect(player.recruitedUnitTypes, isEmpty);
    expect(player.eventState.survivors, isNull);
  });

  test('turning them away adds nobody', () {
    final player = _met(4);
    ActionExecutor().execute(
      ChooseEventAction(accept: false),
      eventGame(player, turn: 12),
      player,
    );
    expect(_harpoonists(player), 0);
    expect(player.eventState.survivors, isNull);
  });

  test('left without a choice, nobody joins', () {
    final player = _met(4);
    EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(_harpoonists(player), 0);
    expect(player.eventState.survivors, isNull);
  });
}
