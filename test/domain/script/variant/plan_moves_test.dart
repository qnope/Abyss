import 'dart:convert';
import 'dart:io';

import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final String source =
      File('scenarios/replays/victoire-tour-85.json').readAsStringSync();

  test('finds the way down to the kernel on a new map', () {
    final script = PlanScript.fromReplay(
      source,
      const ReplayVariant(sameMap: false, sameDice: false, defends: true),
    );

    final report = ScriptRunner(maxTurns: 58).run(script, seed: 1);

    expect(report.milestones.failleCaptured, isNotNull);
    expect(report.milestones.chemineeCaptured, isNotNull);
    expect(report.milestones.kernelCaptured, 50);
    expect(report.log.any((e) => e.description.startsWith('Combat (')), isTrue);
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('plays the same plan with other dice', () {
    final script = PlanScript.fromReplay(
      source,
      const ReplayVariant(sameDice: false),
    );

    final report = ScriptRunner(maxTurns: 40).run(script, seed: 3);

    expect(report.milestones.failleCaptured, 30);
    expect(report.milestones.chemineeCaptured, 39);
  });

  test('searches for a target not revealed yet, and waits for it', () {
    Map<String, Object?> onMap(String verb) => <String, Object?>{
          'do': verb,
          'x': 0,
          'y': 0,
          'units': <String, Object?>{'scout': 1},
        };
    final script = PlanScript.fromReplay(
      jsonEncode(<String, Object?>{
        'turns': <String, Object?>{
          '1': <Object?>[onMap('attackBase'), onMap('descend')],
        },
      }),
      const ReplayVariant(sameMap: false),
    );

    ScriptRunner(maxTurns: 2).run(script, seed: 1);

    expect(
        script.pending.map((s) => s.verb), <String>['attackBase', 'descend']);
  });
}
