// Plays scripted games headless, without Flutter.
//
//   dart run bin/simulate.dart --strategy balanced --games 100
//   dart run bin/simulate.dart --scenario scenarios/rush.json --verbose
//
// Options:
//   --strategy <name>   built-in strategy (economy, balanced, idle)
//   --scenario <file>   JSON scenario (see ScenarioParser)
//   --games <n>         number of games, seeds seed..seed+n-1 (default 20)
//   --seed <n>          first seed (default 1)
//   --turns <n>         turn limit per game (default 60)
//   --verbose           one line per game, plus the action log of game 1
//   --json              print the whole batch as JSON
import 'dart:convert';
import 'dart:io';

import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';

void main(List<String> args) {
  final Map<String, String> options = _parse(args);
  final String? scenario = options['scenario'];
  final GameScript Function() build = scenario != null
      ? () => ScenarioParser.parse(File(scenario).readAsStringSync())
      : () => ScriptLibrary.byName(options['strategy'] ?? 'balanced');
  final BatchReport report = BatchRunner(
    runner: ScriptRunner(maxTurns: int.parse(options['turns'] ?? '60')),
  ).run(
    build,
    games: int.parse(options['games'] ?? '20'),
    firstSeed: int.parse(options['seed'] ?? '1'),
  );
  if (options.containsKey('json')) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'summary': report.toJson(),
      'runs': report.runs.map((r) => r.toJson()).toList(),
    }));
    return;
  }
  if (options.containsKey('verbose')) _printRuns(report);
  _printSummary(build().name, report);
}

Map<String, String> _parse(List<String> args) {
  final Map<String, String> options = <String, String>{};
  for (int i = 0; i < args.length; i++) {
    if (!args[i].startsWith('--')) continue;
    final String key = args[i].substring(2);
    final bool hasValue = i + 1 < args.length && !args[i + 1].startsWith('--');
    options[key] = hasValue ? args[++i] : '';
  }
  return options;
}

void _printRuns(BatchReport report) {
  for (final run in report.runs) {
    stdout.writeln('seed ${run.seed}: ${run.status.name} au tour '
        '${run.turnsPlayed}, raids ${run.raidsRepelled} repoussés / '
        '${run.raidsLost} perdus, bruit ${run.totalNoise}');
  }
  if (report.runs.isNotEmpty) {
    stdout.writeln('\nJournal de la partie seed ${report.runs.first.seed} :');
    report.runs.first.log.forEach(stdout.writeln);
    stdout.writeln();
  }
}

void _printSummary(String name, BatchReport report) {
  String pct(double v) => '${(v * 100).toStringAsFixed(0)} %';
  String avg(double v) => v.toStringAsFixed(1);
  stdout
    ..writeln('Stratégie : $name, ${report.games} parties')
    ..writeln('Survie : ${pct(report.survivalRate)} '
        '(${report.defeats} défaites, ${report.victories} victoires)')
    ..writeln('Tours joués en moyenne : ${avg(report.averageTurns)}')
    ..writeln('Raids repoussés / perdus en moyenne : '
        '${avg(report.averageRaidsRepelled)} / ${avg(report.averageRaidsLost)}')
    ..writeln('Bruit total moyen : ${avg(report.averageNoise)}')
    ..writeln('Première défaite : tour ${report.earliestDefeat ?? '-'}');
}
