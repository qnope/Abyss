import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/idle_script.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

/// The raid calibration targets of step 6, on a few seeds each; the
/// command line replays them on hundreds (see bin/simulate.dart).
void main() {
  final batch = BatchRunner(runner: ScriptRunner(maxTurns: 100));

  test('an all-economy base falls to the raids', () {
    final report = batch.run(() => const EconomyStrategy(), games: 3);

    expect(report.defeats, report.games);
    expect(report.earliestDefeat, lessThan(40));
  });

  test('a base that does nothing falls too, only later', () {
    final report = batch.run(() => const IdleScript(), games: 2);

    expect(report.defeats, report.games);
    expect(report.earliestDefeat, inInclusiveRange(40, 50));
  });

  test('a balanced base holds at least 50 turns, twice the all-economy one',
      () {
    final report = batch.run(() => const BalancedStrategy(), games: 3);

    expect(report.earliestDefeat ?? 100, greaterThanOrEqualTo(50));
    expect(report.averageRaidsRepelled, greaterThan(10));
  });

  test('rushing the volcano without defending loses the base', () {
    final report = batch.run(
      () => const ConquestStrategy(defends: false, name: 'rush'),
      games: 2,
    );

    expect(report.defeats, report.games);
    expect(report.victories, 0);
  });

  // The 15 % target is measured on a human plan (calibration_test.dart);
  // against it, the careful script loses nearly every game.
  test('the careful script no longer wins', () {
    final run =
        ScriptRunner(maxTurns: 100).run(const ConquestStrategy(), seed: 13);

    expect(run.isVictory, isFalse);
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the library knows every built-in strategy by name', () {
    for (final name in ScriptLibrary.names) {
      expect(ScriptLibrary.byName(name).name, name);
    }
    expect(() => ScriptLibrary.byName('nope'), throwsFormatException);
  });
}
