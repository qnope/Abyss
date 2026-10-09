import 'package:abyss/domain/script/batch_report.dart';
import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stops on its first turn, named after the seed it was built for.
class _SeedScript extends GameScript {
  final int seed;

  const _SeedScript(this.seed);

  @override
  String get name => 'seed $seed';

  @override
  int? get lastTurn => 1;

  @override
  void playTurn(ScriptTurn turn) {}
}

void main() {
  final runner = ScriptRunner(maxTurns: 30);
  List<String> names(BatchReport report) =>
      report.runs.map((r) => r.scriptName).toList();

  group('BatchRunner', () {
    test('builds one script per seed, in seed order', () async {
      final report = await BatchRunner(runner: runner)
          .run(_SeedScript.new, games: 4, firstSeed: 5);

      expect(names(report), ['seed 5', 'seed 6', 'seed 7', 'seed 8']);
      expect(report.runs.map((r) => r.seed), [5, 6, 7, 8]);
    });

    test('with several workers, every seed is built once', () async {
      final report = await BatchRunner(runner: runner, workers: 3)
          .run(_SeedScript.new, games: 5, firstSeed: 5);

      expect(names(report),
          unorderedEquals(['seed 5', 'seed 6', 'seed 7', 'seed 8', 'seed 9']));
    });

    test('several workers give the very report of a single one', () async {
      final sequential = await BatchRunner(runner: runner)
          .run((_) => const BalancedStrategy(), games: 6);
      final parallel = await BatchRunner(runner: runner, workers: 3)
          .run((_) => const BalancedStrategy(), games: 6);

      expect(parallel.runs, hasLength(sequential.runs.length));
      for (int i = 0; i < sequential.runs.length; i++) {
        expect(parallel.runs[i].seed, sequential.runs[i].seed);
        expect(parallel.runs[i].toJson(), sequential.runs[i].toJson());
        expect(
          parallel.runs[i].log.map((e) => e.toString()),
          sequential.runs[i].log.map((e) => e.toString()),
        );
      }
      expect(parallel.toJson(), sequential.toJson());
    });

    test('more workers than games still plays every game once', () async {
      final report = await BatchRunner(runner: runner, workers: 8)
          .run(_SeedScript.new, games: 2);

      expect(report.runs.map((r) => r.seed), [1, 2]);
    });

    test('no game at all gives an empty report', () async {
      final report = await BatchRunner(runner: runner, workers: 3)
          .run(_SeedScript.new, games: 0);

      expect(report.runs, isEmpty);
      expect(report.games, 0);
    });
  });
}
