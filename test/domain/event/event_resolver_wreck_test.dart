import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/collect_treasure_action.dart';
import 'package:abyss/domain/event/effects/wreck_effect.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'effects/wreck_test_helper.dart';
import 'event_test_helper.dart';

void main() {
  test('a drawn wreck sinks at once, without waiting for a choice', () {
    var wrecks = 0;
    for (var seed = 0; seed < 60; seed++) {
      final player = wreckPlayer()..eventState.schedule(12);
      final game = wreckGame(player);
      final outcome = EventResolver.resolve(
        game,
        player,
        12,
        random: Random(seed),
      );
      if (outcome.drawn != RandomEventType.wreck) continue;
      wrecks++;
      final state = player.eventState;
      expect(state.hasPending, isFalse);
      expect(state.active, isNull);
      expect(state.lastDrawn, RandomEventType.wreck);
      expect(state.wreckUntilTurn, 12 + EventRules.wreckTurns);
      final at = state.wreckPosition!;
      expect(game.currentMap.cellAt(at.x, at.y).content, CellContentType.wreck);
      final entry = eventEntriesOf(player).single;
      expect(entry.accepted, isTrue);
      expect(entry.subtitle, isNull);
    }
    expect(wrecks, greaterThan(0));
  });

  test('a wreck left alone sinks out of reach after the end of turn 17', () {
    final player = wreckPlayer();
    final game = wreckGame(player);
    const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));
    final at = player.eventState.wreckPosition!;
    for (var turn = 13; turn <= 16; turn++) {
      EventResolver.resolve(game, player, turn, random: Random(turn));
      expect(game.currentMap.cellAt(at.x, at.y).content, CellContentType.wreck);
    }
    EventResolver.resolve(game, player, 17, random: Random(17));
    expect(game.currentMap.cellAt(at.x, at.y).content, CellContentType.empty);
    expect(player.eventState.wreckPosition, isNull);
    expect(player.eventState.wreckUntilTurn, isNull);
  });

  test('a wreck on the map neither holds back the next draw nor repeats', () {
    for (var seed = 0; seed < 40; seed++) {
      final player = wreckPlayer();
      final game = wreckGame(player);
      const WreckEffect().onDraw(game, player, turn: 12, random: Random(seed));
      player.eventState.schedule(14);
      final outcome = EventResolver.resolve(
        game,
        player,
        14,
        random: Random(seed),
      );
      expect(outcome.drawn, isNotNull, reason: 'seed $seed');
      expect(outcome.drawn, isNot(RandomEventType.wreck));
      expect(player.eventState.wreckPosition, isNotNull);
    }
  });

  test('the end of turn 17 tells the sunk wreck and its last turn', () {
    final player = wreckPlayer();
    final game = wreckGame(player);
    const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));
    for (var turn = 13; turn <= 16; turn++) {
      final outcome = EventResolver.resolve(game, player, turn);
      expect(outcome.wreck, isNull);
    }
    final ending = EventResolver.resolve(game, player, 17).wreck!;
    expect(ending.searched, isFalse);
    expect(ending.untilTurn, 17);
  });

  test('a wreck searched during the turn is told at its end, once', () {
    final player = wreckPlayer();
    final game = wreckGame(player, turn: 14);
    const WreckEffect().onDraw(game, player, turn: 12, random: Random(2));
    final at = player.eventState.wreckPosition!;
    player.addRevealedCell(1, at);
    final search = CollectTreasureAction(targetX: at.x, targetY: at.y);
    expect(ActionExecutor().execute(search, game, player).isSuccess, isTrue);
    expect(player.eventState.wreckPosition, isNull);

    final ending = EventResolver.resolve(game, player, 14).wreck!;

    expect(ending.searched, isTrue);
    expect(ending.untilTurn, 17);
    expect(player.eventState.wreckUntilTurn, isNull);
    expect(EventResolver.resolve(game, player, 15).wreck, isNull);
  });
}
