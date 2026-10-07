import 'batch_report.dart';
import 'game_script.dart';
import 'script_run_report.dart';
import 'script_runner.dart';

/// Plays the same script on many seeds, to measure a strategy rather than
/// a lucky game.
class BatchRunner {
  final ScriptRunner runner;

  BatchRunner({ScriptRunner? runner}) : runner = runner ?? ScriptRunner();

  /// Plays [games] games with seeds `firstSeed`, `firstSeed + 1`, ...
  ///
  /// [build] makes a fresh script for each game, so a script that keeps
  /// state between turns never leaks it into the next game.
  BatchReport run(
    GameScript Function() build, {
    required int games,
    int firstSeed = 1,
  }) {
    final List<ScriptRunReport> runs = <ScriptRunReport>[
      for (int i = 0; i < games; i++)
        runner.run(build(), seed: firstSeed + i),
    ];
    return BatchReport(runs);
  }
}
