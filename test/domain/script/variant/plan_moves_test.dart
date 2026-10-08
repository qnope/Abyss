import 'dart:io';

import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String source =
      File('scenarios/replays/victoire-tour-85.json').readAsStringSync();

  test('finds the way down on a new map', () {
    final script = PlanScript.fromReplay(
      source,
      const ReplayVariant(sameMap: false),
    );

    final report = ScriptRunner(maxTurns: 45).run(script, seed: 1);

    expect(report.milestones.failleCaptured, isNotNull);
    expect(report.milestones.chemineeCaptured, isNotNull);
  });

  test('plays the same plan with other dice', () {
    final script = PlanScript.fromReplay(
      source,
      const ReplayVariant(sameDice: false),
    );

    final report = ScriptRunner(maxTurns: 40).run(script, seed: 3);

    expect(report.milestones.failleCaptured, 30);
    expect(report.milestones.chemineeCaptured, 39);
  });
}
