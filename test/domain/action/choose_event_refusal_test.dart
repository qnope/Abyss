import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/event_effects.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event/event_test_helper.dart';

/// Caravan drawn at the end of turn 11 that trades algae for coral, once
/// the algae dropped to [algae] during turn 12.
({Game game, Player player}) _caravan({required int algae}) {
  final player = eventPlayer();
  player.resources[ResourceType.algae]!.amount = 400;
  player.resources[ResourceType.coral]!.amount = 120;
  player.resources[ResourceType.ore]!.amount = 250;
  final game = eventGame(player, turn: 12);
  EventEffects.onDraw(
    game,
    player,
    RandomEventType.caravan,
    turn: 11,
    random: Random(1),
  );
  player.eventState.setPending(RandomEventType.caravan, 12);
  player.resources[ResourceType.algae]!.amount = algae;
  return (game: game, player: player);
}

void main() {
  test('trading fails when the stock to give dropped under 100', () {
    final s = _caravan(algae: 60);
    final result = ActionExecutor().execute(
      ChooseEventAction(accept: true),
      s.game,
      s.player,
    );
    expect(result.isSuccess, isFalse);
    expect(result.reason, 'Stock insuffisant pour échanger');
    expect(s.player.eventState.hasPending, isTrue);
    expect(s.player.eventState.tradeFrom, ResourceType.algae);
    expect(s.player.resources[ResourceType.algae]!.amount, 60);
  });

  test('turning the caravan away still works without the stock', () {
    final s = _caravan(algae: 60);
    final result = ActionExecutor().execute(
      ChooseEventAction(accept: false),
      s.game,
      s.player,
    );
    expect(result.isSuccess, isTrue);
    expect(s.player.eventState.hasPending, isFalse);
    expect(s.player.eventState.tradeFrom, isNull);
    expect(s.player.eventState.tradeTo, isNull);
  });

  test('trading with the stock settles the caravan', () {
    final s = _caravan(algae: 100);
    final result = ActionExecutor().execute(
      ChooseEventAction(accept: true),
      s.game,
      s.player,
    );
    expect(result.isSuccess, isTrue);
    expect(s.player.resources[ResourceType.algae]!.amount, 0);
    expect(s.player.resources[ResourceType.coral]!.amount, 190);
    expect(s.player.eventState.tradeFrom, isNull);
  });
}
