// Win rate of a reference player against factions, by difficulty and by
// number of factions (the balancing of step 14):
//
//   dart run bin/balance_factions.dart --strategy conquest --games 160 \
//       --difficulty normal --factions 3 [--turns 120] [--workers 4]
//
// --strategy is any name of `ScriptLibrary` (conquest, plan85-newmap...).
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/script/among_factions.dart';
import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';

Future<void> main(List<String> args) async {
  final Map<String, String> o = <String, String>{
    for (int i = 0; i + 1 < args.length; i += 2)
      args[i].substring(2): args[i + 1],
  };
  final String strategy = o['strategy'] ?? 'conquest';
  final int factions = int.parse(o['factions'] ?? '3');
  final int games = int.parse(o['games'] ?? '40');
  final Difficulty difficulty = Difficulty.values.byName(
    o['difficulty'] ?? 'normal',
  );
  final BatchReport report = await BatchRunner(
    runner: ScriptRunner(
      maxTurns: int.parse(o['turns'] ?? '120'),
      difficulty: difficulty,
    ),
    workers: int.parse(o['workers'] ?? '${Platform.numberOfProcessors}'),
  ).run(
    (int seed) => AmongFactions.drawn(
      ScriptLibrary.byName(strategy),
      factions,
      seed: seed,
    ),
    games: games,
  );
  print(
    '$strategy | ${difficulty.name} | $factions factions | '
    '${report.victories}/$games wins '
    '(${(100 * report.victories / games).toStringAsFixed(0)} %), '
    '${report.factionVictories} won by a faction, '
    '${report.defeats - report.factionVictories} fell to the raids',
  );
}
