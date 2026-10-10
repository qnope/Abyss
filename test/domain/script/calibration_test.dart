import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/script/script_library.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

/// The calibration targets of the difficulties, measured on the human
/// plan `plan85` (a win, played again with other dice and a careful
/// defence) and the careful script, 160 games each with the random events
/// and the objective rewards (see `Difficulty`): about 50 % of wins in
/// easy, 15 % in normal and 5 % in hard. In normal, seed 92 is one of the
/// plan's wins and seed 49 falls the earliest (turn 55; seed 3 used to,
/// before the rewards let it hold to turn 111); seed 3 wins in easy and
/// falls in normal (seed 2 used to, it now survives easy to turn 120).
void main() {
  ScriptRunner runner(Difficulty d) =>
      ScriptRunner(maxTurns: 120, difficulty: d);

  test('the human plan still wins some games', () {
    final run = runner(
      Difficulty.normal,
    ).run(ScriptLibrary.byName('plan85'), seed: 92);

    expect(run.isVictory, isTrue);
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the human plan can also fall to the raids', () {
    final run = runner(
      Difficulty.normal,
    ).run(ScriptLibrary.byName('plan85'), seed: 49);

    expect(run.isDefeat, isTrue);
    expect(run.turnsPlayed, lessThan(60));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the same plan and dice win in easy and fall in normal', () {
    final easy = runner(
      Difficulty.easy,
    ).run(ScriptLibrary.byName('plan85'), seed: 3);
    final normal = runner(
      Difficulty.normal,
    ).run(ScriptLibrary.byName('plan85'), seed: 3);

    expect(easy.isVictory, isTrue);
    expect(normal.isDefeat, isTrue);
  }, timeout: const Timeout(Duration(minutes: 10)));

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
