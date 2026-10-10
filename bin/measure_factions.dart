// Wall-clock cost of one end of turn against 10 factions (brains included),
// at turns 1, 30 and 60, then the mean and the worst of all turns:
//   dart run bin/measure_factions.dart [factions] [idle]
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';

void main(List<String> args) {
  final int factions = args.isEmpty ? 10 : int.parse(args.first);
  // An idle human leaves the factions an easy prey: attacks included.
  final bool idle = args.contains('idle');
  final Random seeds = Random(4);
  final Game game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: seeds.nextInt(0x7FFFFFFF),
    factionCount: factions,
  );
  final ActionExecutor executor = ActionExecutor();
  const Set<int> measured = <int>{1, 30, 60};
  final List<int> costs = <int>[];
  print('$factions factions, end of turn (human move excluded):');
  while (game.status == GameStatus.playing && game.turn <= 60) {
    if (!idle) {
      const BalancedStrategy().playTurn(
        ScriptTurn(
            game: game, random: SeededRandom(seeds.nextInt(1 << 30)), log: []),
      );
    }
    final Stopwatch watch = Stopwatch()..start();
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      game,
      game.humanPlayer,
    );
    watch.stop();
    final int turn = game.turn - 1;
    costs.add(watch.elapsedMicroseconds);
    if (measured.contains(turn)) {
      print('  turn $turn: ${watch.elapsedMilliseconds} ms');
    }
  }
  final int worst = costs.reduce(max);
  print('  all turns: mean ${costs.fold(0, (s, c) => s + c) ~/ costs.length / 1000}'
      ' ms, worst ${worst / 1000} ms (turn ${costs.indexOf(worst) + 1})');
  print('  status ${game.status.name}, journal '
      '${game.replay!.actions.values.fold(0, (s, l) => s + l.length)} actions');
  for (final f in game.factions) {
    final p = game.players[f.id]!;
    final int levels = p.buildings.values.fold(0, (s, b) => s + b.level);
    final int units = p.unitsPerLevel.values
        .expand((u) => u.values)
        .fold(0, (s, u) => s + u.count);
    print('  ${f.name}: buildings $levels, units $units, raids lost '
        '${p.raidState.raidsLost}, fallen ${p.hasFallen}');
  }
}
