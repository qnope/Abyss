import 'dart:math';

import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/explore_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

ScriptTurn _turn({int scouts = 0}) {
  final game = GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5);
  game.humanPlayer.unitsOnLevel(1)[UnitType.scout]!.count = scouts;
  return ScriptTurn(game: game, random: Random(1), log: <ScriptLogEntry>[]);
}

void main() {
  test('sends each scout to a different frontier cell', () {
    final turn = _turn(scouts: 3);
    turn.explore(1, 2, (_) => 0);

    final orders = turn.player.pendingExplorations;
    expect(orders, hasLength(2));
    expect(orders.first.target, isNot(orders.last.target));
    expect(turn.player.unitsOnLevel(1)[UnitType.scout]!.count, 1);
    final known = turn.player.revealedCellsSetOnLevel(1);
    for (final order in orders) {
      expect(known.contains(order.target), isFalse);
    }
  });

  test('the bias steers the scouts', () {
    final turn = _turn(scouts: 1);
    turn.explore(1, 1, (GridPosition p) => -10.0 * (p.x + p.y));

    final target = turn.player.pendingExplorations.single.target;
    final base = GridPosition(x: turn.player.baseX, y: turn.player.baseY);
    expect(target.x + target.y, lessThan(base.x + base.y));
  });

  // ---------------------------------------------------------------------
  // Golden targets: recorded from the previous implementation, which walked
  // the whole map again for every scout. The one-pass frontier must pick
  // the same cells in the same order.
  // ---------------------------------------------------------------------
  test('picks the same cells as the previous implementation', () {
    final turn = _turn(scouts: 3);
    turn.explore(1, 2, (_) => 0);

    final targets =
        turn.player.pendingExplorations.map((o) => o.target).toList();
    expect(targets, <GridPosition>[
      GridPosition(x: 8, y: 5),
      GridPosition(x: 14, y: 5),
    ]);
  });

  test('picks the same biased cells as the previous implementation', () {
    final turn = _turn(scouts: 3);
    turn.explore(1, 3, (GridPosition p) => -10.0 * (p.x + p.y));

    final targets =
        turn.player.pendingExplorations.map((o) => o.target).toList();
    expect(targets, <GridPosition>[
      GridPosition(x: 8, y: 5),
      GridPosition(x: 10, y: 5),
      GridPosition(x: 8, y: 7),
    ]);
  });

  test('does nothing without scouts', () {
    final turn = _turn();
    turn.explore(1, 2, (_) => 0);
    expect(turn.player.pendingExplorations, isEmpty);
  });

  test('revealedWhere only looks at revealed cells', () {
    final turn = _turn();
    final revealed = turn.revealedWhere(1, (_) => true);
    expect(revealed, hasLength(turn.player.revealedCellsOnLevel(1).length));
    expect(turn.revealedWhere(2, (_) => true), isEmpty);
  });
}
