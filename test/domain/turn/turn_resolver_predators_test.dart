import 'dart:math';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event/effects/predators_test_helper.dart';

/// Game of turn 12 whose predators are faced when [accept] is `true`,
/// baited when `false`, left without a choice when `null`.
Game _game({bool? accept, int lostInARow = 0}) {
  final player = threatenedPlayer();
  player.raidState.lostInARow = lostInARow;
  final game = Game.singlePlayer(player)..turn = 12;
  if (accept != null) ChooseEventAction(accept: accept).execute(game, player);
  return game;
}

void main() {
  test('the turn result carries the fight against the predators', () {
    final game = _game(accept: true);
    final result = TurnResolver().resolve(game, random: Random(2));
    expect(result.predators, isNotNull);
    expect(result.predators!.turn, 12);
    expect(result.predators!.surprise, isTrue);
    expect(result.raid, isNull);
    final entries = game.humanPlayer.historyEntries.whereType<RaidEntry>();
    expect(entries.single.surprise, isTrue);
  });

  test('losing to them never ends the game', () {
    final game = _game(accept: true, lostInARow: 2);
    final result = TurnResolver().resolve(game, random: Random(2));
    expect(result.predators!.victory, isFalse);
    expect(game.status, GameStatus.playing);
    expect(game.humanPlayer.raidState.lostInARow, 2);
  });

  test('no fight when they are baited or left without a choice', () {
    for (final accept in [false, null]) {
      final game = _game(accept: accept);
      final result = TurnResolver().resolve(game, random: Random(2));
      expect(result.predators, isNull, reason: '$accept');
      expect(game.humanPlayer.historyEntries.whereType<RaidEntry>(), isEmpty);
    }
  });
}
