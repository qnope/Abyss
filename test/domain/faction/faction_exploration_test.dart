import 'dart:math';

import 'package:abyss/domain/faction/faction_exploration.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/explore_moves.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

double _bias(GridPosition base, int x, int y) => FactionExploration.bias(
  base: base,
  width: 32,
  height: 32,
  target: GridPosition(x: x, y: y),
);

void main() {
  _brain();
  final corner = GridPosition(x: 3, y: 3);

  test('a cell nearer the centre is worth more than one on the border', () {
    expect(_bias(corner, 9, 9), greaterThan(_bias(corner, 29, 3)));
    expect(_bias(corner, 9, 9), greaterThan(_bias(corner, 3, 0)));
  });

  test('a diagonal step beats a straight one of the same reach', () {
    expect(_bias(corner, 9, 9), greaterThan(_bias(corner, 9, 3)));
    expect(_bias(corner, 9, 9), greaterThan(_bias(corner, 3, 9)));
  });

  test('away from the centre is worth less than staying', () {
    expect(_bias(corner, 0, 0), lessThan(_bias(corner, 3, 3)));
  });

  test('it is symmetric: the opposite corner reasons the same way', () {
    final far = GridPosition(x: 28, y: 28);
    expect(_bias(far, 22, 22), closeTo(_bias(corner, 9, 9), 0.001));
  });

  test('a base at the centre still prefers diagonals to straight lines', () {
    final centre = GridPosition(x: 16, y: 16);
    expect(_bias(centre, 20, 20), greaterThan(_bias(centre, 20, 16)));
  });
}

void _brain() {
  test('the faction brain explores towards the middle of the map', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 7,
      factionCount: 2,
    );
    final player = game.players[game.factions[0].id]!;
    player.unitsOnLevel(1)[UnitType.scout]!.count = 1;
    final turn = ScriptTurn(
      game: game,
      random: Random(1),
      log: <ScriptLogEntry>[],
      player: player,
    );

    turn.explore(1, 1, (p) => FactionExploration.forTurn(turn, p));

    final target = player.pendingExplorations.single.target;
    final w = game.levels[1]!.width;
    double away(GridPosition p) =>
        max((p.x - (w - 1) / 2).abs(), (p.y - (w - 1) / 2).abs());
    expect(
      away(target),
      lessThan(away(GridPosition(x: player.baseX, y: player.baseY))),
    );
  });
}
