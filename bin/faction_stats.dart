// What each faction does, over many games against [factions] factions,
// counted from the replay journal (successful moves only):
//
//   dart run bin/faction_stats.dart --strategy conquest --games 40 \
//       --difficulty easy --factions 10 [--turns 120] [--workers 8]
//   dart run bin/faction_stats.dart --replay replays/replay-Test-tour-67.json
//
// Per faction, their mean and the human, per turn: upgrades, explorations
// and collections by level, attacks (bases, human base, posts, kernels),
// lairs, spies, explorer unlocks and nodes; kernel chances = turns with
// fighters on level 3 while another held a level 7+ kernel, and seen ones.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:abyss/domain/faction/faction_catalogue.dart';
import 'package:abyss/domain/game/cheat_codes.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/script/faction_tally.dart';
import 'package:abyss/domain/script/game_workers.dart';
import 'package:abyss/domain/script/kernel_watch.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';

const List<String> columns = <String>[
  'upgrade', 'explore@1', 'explore@2', 'explore@3', 'collect', 'collect@3',
  'attackPlayer', 'attackHuman', 'announceAttack', 'attackPost', 'attackBase',
  'attackKernel', 'attackHeldKernel', 'fight', 'spy', 'unlock:explorer',
  'research:explorer', 'kernelChance', 'kernelSeen',
];

/// One game, played the way `ScriptRunner.run` and `balance_factions`
/// play it, so a seed gives the same game in the three tools.
({FactionTally tally, int turns, bool won, bool factionWon}) _play(
  int seed, String strategy, int factions, Difficulty d, int maxTurns) {
  final Random random = Random(seed);
  final Game game = GameFactory.newGame(
    playerName: strategy,
    mapSeed: random.nextInt(0x7FFFFFFF),
    difficulty: d,
    personalities: FactionCatalogue.draw(factions, seed: seed),
  );
  CheatCodes.apply(game.humanPlayer);
  final FactionTally tally = FactionTally();
  final report = ScriptRunner(maxTurns: maxTurns, difficulty: d).runOn(
      game, KernelWatch(ScriptLibrary.byName(strategy), tally),
      random: random, seed: seed);
  for (final f in game.factions) {
    tally.played(f.id, report.turnsPlayed);
  }
  tally.played('human', report.turnsPlayed);
  tally.addJournal(game.replay!.actions.keys
      .map((t) => (t, game.replay!.actionsOf(t))));
  return (
    tally: tally,
    turns: report.turnsPlayed,
    won: report.isVictory,
    factionWon: report.factionWon,
  );
}

Future<void> main(List<String> args) async {
  final Map<String, String> o = <String, String>{
    for (int i = 0; i + 1 < args.length; i += 2)
      args[i].substring(2): args[i + 1],
  };
  final FactionTally total = FactionTally();
  int turns = 0, games = 1, wins = 0, factionWins = 0;
  if (o['replay'] case final String path) {
    final json = jsonDecode(File(path).readAsStringSync()) as Map;
    total.addJournal((json['turns'] as Map).entries.map((e) => (
          int.parse(e.key as String),
          (e.value as List).cast<Map<String, Object?>>(),
        )));
    turns = json['lastTurn'] as int;
    for (final String who in [...total.factionIds, 'human']) {
      total.played(who, turns);
    }
  } else {
    final String s = o['strategy'] ?? 'conquest';
    final int n = int.parse(o['factions'] ?? '10');
    final Difficulty d = Difficulty.values.byName(o['difficulty'] ?? 'easy');
    final int max = int.parse(o['turns'] ?? '120');
    games = int.parse(o['games'] ?? '20');
    final runs = await GameWorkers(
      int.parse(o['workers'] ?? '${Platform.numberOfProcessors}'),
    ).map(games, (int i) => _play(i + 1, s, n, d, max));
    for (final r in runs) {
      total.merge(r.tally);
      turns += r.turns;
      if (r.won) wins++;
      if (r.factionWon) factionWins++;
    }
    print('$s | ${d.name} | $n factions | $wins/$games human wins, '
        '$factionWins faction wins');
  }
  print('per turn (${turns ~/ games} turns a game): ${columns.join(' | ')}');
  String row(double Function(String) per) =>
      columns.map((k) => per(k).toStringAsFixed(2)).join(' | ');
  for (final String who in total.factionIds) {
    print('$who: ${row((k) => total.perTurn(who, k))}');
  }
  print('factions mean: ${row(total.factionMean)}');
  print('human: ${row((k) => total.perTurn('human', k))}');
  print('held-kernel attacks by kernel level: ${total.heldKernelByLevel}');
}
