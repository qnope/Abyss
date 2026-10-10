import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String replay(Map<String, Object?> turns) => jsonEncode(<String, Object?>{
        'name': 'plan',
        'player': 'Test',
        'mapSeed': 42,
        'turns': turns,
      });

  final String upgrades = replay(<String, Object?>{
    '1': <Object?>[
      <String, Object?>{'do': 'upgrade', 'building': 'headquarters'},
    ],
    '4': <Object?>[
      <String, Object?>{'do': 'upgrade', 'building': 'algaeFarm'},
    ],
  });

  test('plays the human plan again on the same map and dice', () {
    final String source =
        File('scenarios/replays/victoire-tour-85.json').readAsStringSync();
    final script = PlanScript.fromReplay(source, const ReplayVariant());

    final report = ScriptRunner(maxTurns: 50).run(script, seed: 1);

    // The replay predates the research choices: with its three branches
    // open, research costs twice as much and some of it comes too dear.
    expect(report.milestones.failleCaptured, 32);
    expect(report.milestones.chemineeCaptured, 39);
    expect(report.milestones.kernelCaptured, 50);
    // The map now holds a third of the treasures it was played with:
    // collects on cells left empty fail, and the loot comes at other
    // turns, so a few more actions than the 21 above lack resources. The
    // monster families change the lair fights and the raid waves too, and
    // the normal difficulty makes the raid waves 6 % smaller, so the
    // stocks ran short 25 times. The rewards of the objectives, credited
    // at the end of the turns, fill the stocks back up: 4 of those
    // actions no longer lack resources.
    final failures = report.log.where((e) => !e.success);
    expect(failures.where((e) => e.reason != 'Rien à collecter').length, 21);
  });

  test('plays each turn later with a stretch and a jitter', () {
    final stretched = PlanScript.fromReplay(
      upgrades,
      const ReplayVariant(stretch: 1.5),
    );
    final jittered = PlanScript.fromReplay(
      upgrades,
      const ReplayVariant(jitter: 2),
      random: Random(3),
    );

    expect(stretched.pending.map((s) => s.turn), <int>[2, 6]);
    for (final step in jittered.pending) {
      expect(step.turn - <int>[1, 4][step.rank], inInclusiveRange(0, 2));
    }
  });

  test('draws the delays from the game dice when given none', () {
    final script =
        PlanScript.fromReplay(upgrades, const ReplayVariant(jitter: 2));

    expect(script.pending.map((s) => s.turn), <int>[1, 4]);
    ScriptRunner(maxTurns: 1).run(script, seed: 5);
    final int late = script.pending.last.turn - 4;
    expect(late, inInclusiveRange(0, 2));
  });

  test('pins the map and raids only while it keeps the dice', () {
    final source = jsonEncode(<String, Object?>{
      'mapSeed': 42,
      'turns': <String, Object?>{},
      'endTurnSeeds': <String, Object?>{'1': 5},
    });
    PlanScript of(ReplayVariant v) => PlanScript.fromReplay(source, v);

    expect(of(const ReplayVariant()).mapSeed, 42);
    expect(of(const ReplayVariant()).endTurnRandom(1), isNotNull);
    expect(of(const ReplayVariant(sameDice: false)).endTurnRandom(1), isNull);
    expect(of(const ReplayVariant(sameMap: false)).mapSeed, isNull);
  });

  test('tries a failed step again, then gives it up', () {
    final script = PlanScript.fromReplay(
      replay(<String, Object?>{
        '1': <Object?>[
          <String, Object?>{'do': 'upgrade', 'building': 'barracks'},
        ],
      }),
      const ReplayVariant(patience: 2),
    );

    final report = ScriptRunner(maxTurns: 6).run(script, seed: 1);

    expect(report.log.map((e) => e.turn), <int>[1, 2, 3]);
    expect(script.pending, isEmpty);
  });

  test('waits as long as it takes for a step on the road', () {
    final script = PlanScript.fromReplay(
      replay(<String, Object?>{
        '1': <Object?>[
          <String, Object?>{
            'do': 'attackKernel',
            'x': 10,
            'y': 10,
            'level': 3,
            'units': <String, Object?>{'harpoonist': 1},
          },
        ],
      }),
      const ReplayVariant(sameMap: false, patience: 1),
    );

    ScriptRunner(maxTurns: 5).run(script, seed: 1);

    expect(script.pending, hasLength(1));
  });

  test('recruits for the announced raids when it defends', () {
    final String source =
        File('scenarios/replays/victoire-tour-85.json').readAsStringSync();
    int recruits(ReplayVariant v) => ScriptRunner(maxTurns: 60)
        .run(PlanScript.fromReplay(source, v), seed: 2)
        .log
        .where((e) => e.success && e.description.startsWith('Recruter'))
        .length;

    // With the original dice, the plan's own army beats every raid of the
    // normal difficulty; other dice bring raids it has to answer.
    expect(recruits(const ReplayVariant(defends: true, sameDice: false)),
        greaterThan(recruits(const ReplayVariant(sameDice: false))));
  });
}
