import 'batch_report.dart';
import 'game_script.dart';
import 'game_workers.dart';
import 'script_run_report.dart';
import 'script_runner.dart';

/// Plays the same script on many seeds, to measure a strategy rather than
/// a lucky game.
class BatchRunner {
  final ScriptRunner runner;

  /// Games played at the same time, each in its own isolate; 1 plays them
  /// one after the other on the calling isolate.
  final int workers;

  BatchRunner({ScriptRunner? runner, this.workers = 1})
      : assert(workers >= 1),
        runner = runner ?? ScriptRunner();

  /// Plays [games] games with seeds `firstSeed`, `firstSeed + 1`, ...
  ///
  /// [build] makes a fresh script for the seed of each game, so a script
  /// that keeps state between turns never leaks it into the next game.
  /// The runs come back in seed order whatever the number of workers.
  Future<BatchReport> run(
    GameScript Function(int seed) build, {
    required int games,
    int firstSeed = 1,
  }) async {
    ScriptRunReport play(int i) =>
        runner.run(build(firstSeed + i), seed: firstSeed + i);
    if (workers == 1) {
      return BatchReport(<ScriptRunReport>[
        for (int i = 0; i < games; i++) play(i),
      ]);
    }
    return BatchReport(await GameWorkers(workers).map(games, play));
  }
}
