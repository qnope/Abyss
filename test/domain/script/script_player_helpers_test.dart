import 'dart:math';

import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_milestones.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/expedition_moves.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';

void main() {
  test('ownBase and openBase answer for the turn player', () {
    final two = TwoPlayerGame.create();
    final map = two.game.levels[1]!;
    final MapCell faille = map.cells.firstWhere(
      (c) => c.content == CellContentType.transitionBase,
    );
    final int i = map.cells.indexOf(faille);
    final GridPosition at = GridPosition(x: i % map.width, y: i ~/ map.width);
    for (final p in [two.human, two.rival]) {
      p.addRevealedCell(1, at);
    }
    ScriptTurn turnOf(Player player) => ScriptTurn(
      game: two.game,
      random: Random(1),
      log: <ScriptLogEntry>[],
      player: player,
    );

    expect(turnOf(two.rival).openBase(1), at);
    expect(turnOf(two.rival).ownBase(1), isNull);

    faille.transitionBase!.capturedBy = two.rival.id;

    expect(turnOf(two.rival).ownBase(1), at);
    expect(turnOf(two.human).ownBase(1), isNull);
    expect(turnOf(two.human).openBase(1), isNull);
  });

  test('milestones follow the player they are asked about', () {
    final two = TwoPlayerGame.create();
    final faille = two.game.levels[1]!.cells.firstWhere(
      (c) => c.content == CellContentType.transitionBase,
    );
    faille.transitionBase!.capturedBy = two.rival.id;

    final human = ScriptMilestones()..observe(two.game, 5);
    final rival =
        ScriptMilestones()..observe(two.game, 5, playerId: two.rival.id);

    expect(human.failleCaptured ?? human.chemineeCaptured, isNull);
    expect(rival.failleCaptured ?? rival.chemineeCaptured, 5);
  });
}
