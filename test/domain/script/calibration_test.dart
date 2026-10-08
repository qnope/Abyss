import 'dart:io';

import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:flutter_test/flutter_test.dart';

/// The raid calibration target: a human plan that won, played again with
/// other dice and a careful defence, wins about 15 % of the games (16 on
/// 100 seeds). Seed 23 is one of the wins, seed 37 falls the earliest.
void main() {
  final String source =
      File('scenarios/replays/victoire-tour-85.json').readAsStringSync();
  const ReplayVariant variant = ReplayVariant(sameDice: false, defends: true);

  test('the human plan can still win with other dice', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(PlanScript.fromReplay(source, variant), seed: 23);

    expect(run.isVictory, isTrue);
    expect(run.milestones.kernelCaptured, lessThan(run.turnsPlayed));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('the human plan can also fall to the raids', () {
    final run = ScriptRunner(maxTurns: 120)
        .run(PlanScript.fromReplay(source, variant), seed: 37);

    expect(run.isDefeat, isTrue);
    expect(run.turnsPlayed, lessThan(60));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
