import 'dart:math';

import 'package:abyss/domain/action/action_failure.dart';
import 'package:abyss/domain/event/effects/caravan_effect.dart';
import 'package:abyss/domain/event/event_effects.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event_test_helper.dart';

const _caravan = CaravanEffect();

/// Player holding [algae], [coral] and [ore], and plenty of energy.
Player _stocked(int algae, int coral, int ore) {
  final player = eventPlayer();
  final amounts = {
    ResourceType.algae: algae,
    ResourceType.coral: coral,
    ResourceType.ore: ore,
    ResourceType.energy: 900,
  };
  amounts.forEach((type, amount) => player.resources[type]!.amount = amount);
  return player;
}

/// [player] once the caravan is drawn at the end of turn 11.
Player _drawn(Player player) {
  _caravan.onDraw(
    eventGame(player, turn: 11),
    player,
    turn: 11,
    random: Random(1),
  );
  return player;
}

int _amount(Player player, ResourceType type) => player.resources[type]!.amount;

void main() {
  test('trades the most abundant of algae, coral and ore for the scarcest', () {
    final state = _drawn(_stocked(400, 120, 250)).eventState;
    expect(state.tradeFrom, ResourceType.algae);
    expect(state.tradeTo, ResourceType.coral);
  });

  test('ties go to the first resource in the usual order', () {
    final first = _drawn(_stocked(200, 200, 50)).eventState;
    expect(first.tradeFrom, ResourceType.algae);
    expect(first.tradeTo, ResourceType.ore);
    final last = _drawn(_stocked(50, 300, 50)).eventState;
    expect(last.tradeFrom, ResourceType.coral);
    expect(last.tradeTo, ResourceType.algae);
  });

  test('never drawn when the most abundant stock is under 100', () {
    final poor = _stocked(99, 50, 20);
    expect(_caravan.allowedAt(eventGame(poor), poor, 11), isFalse);
    expect(
      EventEffects.excludedAt(eventGame(poor), poor, 11),
      contains(RandomEventType.caravan),
    );
    final enough = _stocked(100, 50, 20);
    expect(_caravan.allowedAt(eventGame(enough), enough, 11), isTrue);
  });

  test('never drawn when the three stocks are equal', () {
    final even = _stocked(300, 300, 300);
    expect(_caravan.allowedAt(eventGame(even), even, 11), isFalse);
  });

  test('trading gives 100 of the abundant stock for 70 of the scarce', () {
    final player = _drawn(_stocked(400, 120, 250));
    _caravan.apply(eventGame(player, turn: 12), player, accept: true, turn: 12);
    expect(_amount(player, ResourceType.algae), 300);
    expect(_amount(player, ResourceType.coral), 190);
    expect(_amount(player, ResourceType.ore), 250);
  });

  test('what the caravan gives stops at the storage cap', () {
    final player = _drawn(_stocked(400, 120, 250));
    player.resources[ResourceType.coral] = Resource(
      type: ResourceType.coral,
      amount: 120,
      maxStorage: 150,
    );
    _caravan.apply(eventGame(player, turn: 12), player, accept: true, turn: 12);
    expect(_amount(player, ResourceType.algae), 300);
    expect(_amount(player, ResourceType.coral), 150);
  });

  test('turning the caravan away changes nothing', () {
    final player = _drawn(_stocked(400, 120, 250));
    _caravan.apply(
      eventGame(player, turn: 12),
      player,
      accept: false,
      turn: 13,
    );
    expect(_amount(player, ResourceType.algae), 400);
    expect(_amount(player, ResourceType.coral), 120);
  });

  test('trading is refused once the stock dropped under 100', () {
    final player = _drawn(_stocked(400, 120, 250));
    final game = eventGame(player, turn: 12);
    expect(_caravan.refusal(game, player), isNull);
    player.resources[ResourceType.algae]!.amount = 99;
    expect(_caravan.refusal(game, player), ActionFailure.notEnoughStockToTrade);
  });

  test('without a drawn trade there is nothing to refuse nor to trade', () {
    final player = _stocked(400, 120, 250);
    final game = eventGame(player, turn: 12);
    expect(_caravan.refusal(game, player), isNull);
    _caravan.apply(game, player, accept: true, turn: 12);
    expect(_amount(player, ResourceType.algae), 400);
  });
}
