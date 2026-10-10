import 'dart:convert';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_game.dart';

void main() {
  for (final count in [3, 10]) {
    test('$count factions play 60 turns and every one of them grows', () {
      final fresh = playFactionGame(count, 1);
      final before = {
        for (final f in fresh.factions) f.id: growthOf(fresh.players[f.id]!),
      };

      final game = playFactionGame(count, 60);

      expect(game.status, GameStatus.playing);
      expect(game.turn, 60);
      for (final faction in game.factions) {
        final player = game.players[faction.id]!;
        expect(
          growthOf(player),
          greaterThan(before[faction.id]! + 5),
          reason: faction.name,
        );
        expect(player.historyEntries, isNotEmpty);
      }
    });
  }

  test('the factions play after the human, in a fixed order, and are journalled',
      () {
    final game = playFactionGame(3, 3);
    final ids = game.factions.map((f) => f.id).toList();
    final turn1 = game.replay!.actionsOf(1);
    final actors = [for (final a in turn1) a['player'] as String?];

    final firstFaction = actors.indexWhere((a) => a != null);
    expect(firstFaction, greaterThan(0));
    expect(actors.sublist(0, firstFaction), everyElement(isNull));
    final order = actors.whereType<String>().toList();
    for (final id in ids) {
      expect(order, contains(id));
    }
    final firsts = [for (final id in ids) order.indexOf(id)];
    expect(firsts, [...firsts]..sort());
    expect(game.replay!.exact, isTrue);
  });

  test('the switch off leaves the factions idle', () {
    final game = playFactionGame(3, 1);
    final snapshot = jsonEncode([
      for (final f in game.factions) growthOf(game.players[f.id]!),
    ]);

    ActionExecutor().execute(
      EndTurnAction(playFactions: false),
      game,
      game.humanPlayer,
    );

    expect(game.turn, 2);
    expect(
      jsonEncode([for (final f in game.factions) growthOf(game.players[f.id]!)]),
      snapshot,
    );
    expect(game.replay!.actionsOf(1).where((a) => a['player'] != null), isEmpty);
  });

  test('a faction that lost 3 raids in a row falls and stops playing', () {
    final game = playFactionGame(2, 5);
    final victim = game.players[game.factions.first.id]!;
    final other = game.players[game.factions.last.id]!;
    final post = _firstTransitionBase(game)..capturedBy = victim.id;
    victim.raidState.lostInARow = 3;
    final fallTurn = game.turn;

    ActionExecutor().execute(EndTurnAction(), game, game.humanPlayer);
    final victimGrowth = growthOf(victim);
    final otherGrowth = growthOf(other);
    for (var i = 0; i < 3; i++) {
      ActionExecutor().execute(EndTurnAction(), game, game.humanPlayer);
    }

    expect(victim.hasFallen, isTrue);
    expect(other.hasFallen, isFalse);
    expect(game.status, GameStatus.playing, reason: 'only the human can lose');
    expect(post.capturedBy, isNull);
    expect(growthOf(victim), victimGrowth);
    expect(growthOf(other), greaterThan(otherGrowth));
    for (var t = fallTurn + 1; t < game.turn; t++) {
      expect(
        game.replay!.actionsOf(t).where((a) => a['player'] == victim.id),
        isEmpty,
      );
    }
  });
}

TransitionBase _firstTransitionBase(Game game) {
  for (final map in game.levels.values) {
    for (final cell in map.cells) {
      if (cell.transitionBase != null) return cell.transitionBase!;
    }
  }
  throw StateError('no transition base');
}
