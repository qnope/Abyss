import 'dart:math';

import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/growth_moves.dart';
import 'package:flutter_test/flutter_test.dart';

ScriptTurn _turn() => ScriptTurn(
  game: GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5),
  random: Random(1),
  log: <ScriptLogEntry>[],
);

void main() {
  test('the energy margin counts the heating of the farms', () {
    final ScriptTurn calm = _turn();
    final ScriptTurn heated = _turn();
    heated.player.eventState
      ..activate(RandomEventType.coldCurrent, untilTurn: heated.game.turn)
      ..heating = true;
    expect(
      heated.energyMargin,
      calm.energyMargin - EventRules.heatingEnergyPerTurn,
    );
  });
}
