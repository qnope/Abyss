import 'package:abyss/domain/script/batch_runner.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final batch = BatchRunner(runner: ScriptRunner(maxTurns: 40));

  test('an all-economy base falls to the raids', () {
    final report = batch.run(() => const EconomyStrategy(), games: 3);

    expect(report.defeats, report.games);
    expect(report.survivalRate, 0);
    expect(report.earliestDefeat, isNotNull);
  });

  test('a balanced base holds against the raids', () {
    final report = batch.run(() => const BalancedStrategy(), games: 3);

    expect(report.defeats, 0);
    expect(report.survivalRate, 1);
    expect(report.averageRaidsRepelled, greaterThan(0));
  });

  test('the library knows every built-in strategy by name', () {
    for (final name in ScriptLibrary.names) {
      expect(ScriptLibrary.byName(name).name, name);
    }
    expect(() => ScriptLibrary.byName('nope'), throwsFormatException);
  });
}
