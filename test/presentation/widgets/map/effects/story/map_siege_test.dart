import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_timeline.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sprite = 'assets/icons/monsters/medium.svg';
  const timeline = SiegeTimeline();
  const after = Duration(milliseconds: 40);
  const fought = <StrikeRound>[
    (dealt: 10, taken: 5),
    (dealt: 0, taken: 3),
    (dealt: 7, taken: 0),
  ];

  MapSiegeRun runOf(
          {required bool victory, List<StrikeRound> rounds = const []}) =>
      MapSiege(
        place: (5, 5),
        victory: victory,
        attackerSprite: sprite,
        rounds: rounds,
      ).stage(MapStage(originOf: (cell) => cell)) as MapSiegeRun;

  test('loads the attackers and centres the map on the place', () {
    const siege =
        MapSiege(place: (5, 5), victory: true, attackerSprite: sprite);
    expect(siege.imagePaths, {sprite});
    expect(siege.focus, (5, 5));
    expect(siege.rounds, isEmpty);
  });

  test('a repelled siege raises the shield; a lost one never does', () {
    expect(runOf(victory: true).shieldAt(timeline.impact), greaterThan(0.9));
    expect(runOf(victory: false).shieldAt(timeline.impact), 0);
  });

  test('a lost siege shakes the map as the attackers break in', () {
    final lost = runOf(victory: false), won = runOf(victory: true);
    expect(lost.shakeAt(timeline.impact + after), isNot(Offset.zero));
    expect(lost.shakeAt(Duration.zero), Offset.zero);
    expect(lost.shakeAt(lost.duration), Offset.zero);
    expect(won.shakeAt(timeline.impact + after), Offset.zero);
  });

  test('every clash shakes the map lightly, won or lost', () {
    for (final victory in [true, false]) {
      final run = runOf(victory: victory, rounds: fought);
      final clashes = run.timeline.clashes;
      for (var i = 0; i < fought.length; i++) {
        final shake = run.shakeAt(clashes.hitAt(i) + after);
        expect(shake, isNot(Offset.zero));
        expect(shake.dx.abs(),
            lessThanOrEqualTo(MapSiegeRun.clashShakeAmplitude));
      }
      expect(run.shakeAt(clashes.start), Offset.zero);
    }
  });

  test('the attackers lunge at the place at each clash', () {
    final run = runOf(victory: true, rounds: fought);
    final clashes = run.timeline.clashes;
    expect(run.timeline.rounds, fought.length);
    expect(clashes.reachAt(clashes.hitAt(1)), closeTo(1, 1e-9));
  });

  test('each clash floats up what each side lost, and nothing for none',
      () {
    final run = runOf(victory: true, rounds: fought);
    int numbersAt(Duration t) {
      final canvas = _NumberCanvas();
      run.paint(canvas, t);
      return canvas.numbers;
    }

    final clashes = run.timeline.clashes;
    expect(numbersAt(clashes.start), 0);
    expect(numbersAt(clashes.hitAt(0) + after), 2);
    expect(numbersAt(clashes.hitAt(1) + after), 1);
    expect(numbersAt(clashes.hitAt(2) + after), 1);
    expect(numbersAt(run.duration), 0);
  });

  test('lasts its timeline, longer with every round of the fight', () {
    expect(runOf(victory: true).duration, timeline.total);
    final run = runOf(victory: true, rounds: fought);
    expect(run.duration, SiegeTimeline(rounds: fought.length).total);
    expect(run.duration, greaterThan(timeline.total));
  });

  test('paints every moment of a repelled and of a lost siege', () {
    for (final victory in [true, false]) {
      for (final rounds in [const <StrikeRound>[], fought]) {
        final run = runOf(victory: victory, rounds: rounds);
        for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
          final recorder = ui.PictureRecorder();
          run.paint(Canvas(recorder), Duration(milliseconds: ms));
          recorder.endRecording().dispose();
        }
      }
    }
  });
}

/// A canvas counting the texts drawn on it, ignoring everything else.
class _NumberCanvas implements Canvas {
  var numbers = 0;

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) => numbers++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
