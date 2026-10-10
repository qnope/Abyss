import 'dart:math';

import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/assault_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/base_attack_helper.dart';

void main() {
  ScriptTurn turnOf(two) =>
      ScriptTurn(game: two.game, random: Random(1), log: <ScriptLogEntry>[]);

  test('a script attacks a given player with the army it picks', () {
    final two = assaultGame();
    station(two.human, horde);

    final done = turnOf(two).attackBase(two.rival.id, horde);

    expect(done, isTrue);
    expect(two.rival.historyEntries, isNotEmpty);
  });

  test('a refused attack is just false, and plays nothing', () {
    final two = assaultGame(turn: 3);
    station(two.human, horde);

    final done = turnOf(two).attackBase(two.rival.id, horde);

    expect(done, isFalse);
    expect(standing(two.human, UnitType.harpoonist), 40);
  });
}
