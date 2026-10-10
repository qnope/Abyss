import 'dart:math';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/recruit_moves.dart';
import 'package:flutter_test/flutter_test.dart';

ScriptTurn _turn(Difficulty difficulty) {
  final game = GameFactory.newSinglePlayer(
    playerName: 'p',
    mapSeed: 5,
    difficulty: difficulty,
  );
  game.humanPlayer.buildings[BuildingType.algaeFarm]!.level = 5;
  return ScriptTurn(game: game, random: Random(1), log: <ScriptLogEntry>[]);
}

void main() {
  test('the algae margin counts the production of the difficulty', () {
    final int easy = _turn(Difficulty.easy).algaeMargin;
    final int normal = _turn(Difficulty.normal).algaeMargin;
    final int hard = _turn(Difficulty.hard).algaeMargin;

    expect(easy, greaterThan(normal));
    expect(hard, lessThan(normal));
  });

  test('the algae margin counts a cold current endured this turn', () {
    final ScriptTurn calm = _turn(Difficulty.normal);
    final ScriptTurn cold = _turn(Difficulty.normal);
    cold.player.eventState.activate(
      RandomEventType.coldCurrent,
      untilTurn: cold.game.turn,
    );
    expect(cold.algaeMargin, lessThan(calm.algaeMargin));
  });
}
