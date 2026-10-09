import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

/// The raid calibration target: the human plan `plan85` (a win, played
/// again with other dice and a careful defence) wins about 15 % of the
/// games (16 on 100 seeds). Seed 23 is one of the wins, seed 37 falls the
/// earliest.
void main() {
  test('the human plan can still win with other dice', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(ScriptLibrary.byName('plan85'), seed: 23);

    expect(run.isVictory, isTrue);
    expect(run.milestones.kernelCaptured, lessThan(run.turnsPlayed));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the human plan can also fall to the raids', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(ScriptLibrary.byName('plan85'), seed: 37);

    expect(run.isDefeat, isTrue);
    expect(run.turnsPlayed, lessThan(60));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('every nearby plan is a strategy of its own', () {
    for (final String name in <String>[
      'plan85-newmap',
      'plan85-nodefence',
      'plan85-army120',
      'plan85-army90',
      'plan85-late',
      'plan85-slow',
    ]) {
      expect(ScriptLibrary.byName(name).name, name);
    }
  });
}
