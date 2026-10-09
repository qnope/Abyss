// Plays scripted games headless, without Flutter.
//
//   dart run bin/simulate.dart --strategy balanced --games 100
//   dart run bin/simulate.dart --scenario scenarios/rush.json --verbose
//   dart run bin/simulate.dart --scenario replay-qnope-tour-42.json \
//       --games 1 --verbose
//
// A replay exported from the game ("Exporter la partie") is a scenario that
// pins the map, the player and every die: it plays that very game again,
// up to the turn it was exported on, whatever --seed and --turns say.
//
// Options:
//   --strategy <name>   built-in strategy (economy, balanced, idle, conquest,
//                       rush) or human plan (plan85, plan85-newmap,
//                       plan85-nodefence, plan85-army120, plan85-army90,
//                       plan85-late, plan85-slow; see PlanLibrary)
//   --scenario <file>   JSON scenario (see ScenarioParser)
//   --games <n>         number of games, seeds seed..seed+n-1 (default 20)
//   --seed <n>          first seed (default 1)
//   --turns <n>         turn limit per game (default 60)
//   --workers <n>       games played at once, one isolate each (default:
//                       the number of processor cores)
//   --verbose           one line per game, plus the action log of game 1
//   --json              print the whole batch as JSON
//   --difficulty <d>    easy, normal (default) or hard; an exported
//                       --scenario keeps the difficulty it was played in
//
// Variants of a replay (the plan of the human, moved away from the game):
//   --replay <file>     exported replay to vary
//   --new-map           a new map per seed; map actions aim at what is
//                       revealed there instead of the original cells
//   --new-dice          the seed rolls fights, loot and raids
//   --army <f>          recruits of fighters × f (default 1)
//   --jitter <n>        each turn of the plan played 0 to n turns late
//   --stretch <f>       turn t of the plan played at turn t × f
//   --patience <n>      turns a failed step is tried again (default 6)
//   --defends           recruits for every announced raid, as conquest does
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_run_report.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';

Future<void> main(List<String> args) async {
  final Map<String, String> options = _parse(args);
  final String? scenario = options['scenario'];
  final String? replay = options['replay'];
  final GameScript Function(int seed) build = replay != null
      ? _variantOf(File(replay).readAsStringSync(), options)
      : scenario != null
          ? (_) => ScenarioParser.parse(File(scenario).readAsStringSync())
          : (_) => ScriptLibrary.byName(options['strategy'] ?? 'balanced');
  final int firstSeed = int.parse(options['seed'] ?? '1');
  final BatchReport report = await BatchRunner(
    runner: ScriptRunner(
      maxTurns: int.parse(options['turns'] ?? '60'),
      difficulty: Difficulty.values.byName(options['difficulty'] ?? 'normal'),
    ),
    workers: int.parse(options['workers'] ?? '${Platform.numberOfProcessors}'),
  ).run(
    build,
    games: int.parse(options['games'] ?? '20'),
    firstSeed: firstSeed,
  );
  if (options.containsKey('json')) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'summary': report.toJson(),
      'runs': report.runs.map((r) => r.toJson()).toList(),
    }));
    return;
  }
  if (options.containsKey('verbose')) _printRuns(report);
  _printSummary(build(firstSeed).name, report);
}

GameScript Function(int) _variantOf(String source, Map<String, String> o) {
  final ReplayVariant variant = ReplayVariant(
    sameMap: !o.containsKey('new-map'),
    sameDice: !o.containsKey('new-dice'),
    army: double.parse(o['army'] ?? '1'),
    jitter: int.parse(o['jitter'] ?? '0'),
    stretch: double.parse(o['stretch'] ?? '1'),
    patience: int.parse(o['patience'] ?? '6'),
    defends: o.containsKey('defends'),
  );
  return (int seed) =>
      PlanScript.fromReplay(source, variant, random: Random(seed));
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
  _printMilestone(report, 'Faille prise', (r) => r.milestones.failleCaptured);
  _printMilestone(
      report, 'Cheminée prise', (r) => r.milestones.chemineeCaptured);
  _printMilestone(report, 'Noyau pris', (r) => r.milestones.kernelCaptured);
  _printMilestone(
      report, 'Victoire', (r) => r.isVictory ? r.turnsPlayed : null);
}

void _printMilestone(
  BatchReport report,
  String label,
  int? Function(ScriptRunReport) turnOf,
) {
  final m = report.milestone(turnOf);
  if (m.games == 0) return;
  stdout.writeln('$label : ${m.games}/${report.games} parties, '
      'tour ${m.averageTurn!.toStringAsFixed(1)} en moyenne');
}
