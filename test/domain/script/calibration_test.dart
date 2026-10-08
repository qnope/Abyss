import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

/// The raid calibration target: the strongest nearby plan of a human win,
/// `plan85-army120` (other dice, a careful defence, 20 % more fighters),
/// wins about 15 % of the games (13 on 100 seeds). Seed 2 is one of the
/// wins, seed 1 falls the earliest.
void main() {
  test('the strongest nearby plan can still win', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(ScriptLibrary.byName('plan85-army120'), seed: 2);

    expect(run.isVictory, isTrue);
    expect(run.milestones.kernelCaptured, lessThan(run.turnsPlayed));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the strongest nearby plan can also fall to the raids', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(ScriptLibrary.byName('plan85-army120'), seed: 1);

    expect(run.isDefeat, isTrue);
    expect(run.turnsPlayed, lessThan(60));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('every nearby plan is a strategy of its own', () {
    for (final String name in <String>[
      'plan85-newmap',
      'plan85-nodefence',
      'plan85',
      'plan85-army90',
      'plan85-late',
      'plan85-slow',
    ]) {
      expect(ScriptLibrary.byName(name).name, name);
    }
  });
}
