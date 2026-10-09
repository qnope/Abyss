import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

/// A cold `flutter test` run of this game takes about 0.8 s (0.5 s warm,
/// the same with `--coverage`) against about 40 s before the simulation
/// speed-ups: ten times the measurement absorbs a slow CI runner and
/// still catches such a regression.
const Duration budget = Duration(seconds: 8);

void main() {
  group('ScriptRunner performance', () {
    test('a scripted conquest of 100 turns stays within the time budget', () {
      final stopwatch = Stopwatch()..start();
      final report = ScriptRunner(maxTurns: 100)
          .run(ScriptLibrary.byName('conquest'), seed: 1);
      stopwatch.stop();

      expect(report.turnsPlayed, 100);
      expect(
        stopwatch.elapsed,
        lessThan(budget),
        reason: 'the game took ${stopwatch.elapsedMilliseconds} ms',
      );
    });
  });
}
