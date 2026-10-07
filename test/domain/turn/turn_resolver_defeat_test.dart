import 'dart:math';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_resolver.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

const _wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 5);

Game _gameWithRaidDue({required int lostInARow}) {
  final player = Player(id: 'h', name: 'Human', baseX: 5, baseY: 5);
  player.raidState
    ..lostInARow = lostInARow
    ..announce(_wave, 12);
  return Game.singlePlayer(player)..turn = 12;
}

void main() {
  test('losing a third raid in a row ends the game', () {
    final game = _gameWithRaidDue(lostInARow: 2);
    final result = TurnResolver().resolve(game);
    expect(result.raid!.victory, isFalse);
    expect(game.status, GameStatus.defeat);
  });

  test('losing a second raid in a row keeps the game going', () {
    final game = _gameWithRaidDue(lostInARow: 1);
    TurnResolver().resolve(game);
    expect(game.humanPlayer.raidState.lostInARow, 2);
    expect(game.status, GameStatus.playing);
  });

  test('raid outcomes are counted for the statistics', () {
    final player = Player(id: 'h', name: 'Human');
    player.raidState.announce(_wave, 12);
    RaidResolver.resolve(player, 12, random: Random(1));
    player.raidState.recordOutcome(victory: true);
    expect(player.raidState.raidsLost, 1);
    expect(player.raidState.raidsRepelled, 1);
    expect(player.raidState.lostInARow, 0);
  });
}
