import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_timeline.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sprite = 'assets/icons/monsters/medium.svg';
  const timeline = SiegeTimeline();

  MapSiegeRun runOf({required bool victory}) => MapSiege(
        place: (5, 5),
        victory: victory,
        attackerSprite: sprite,
      ).stage(MapStage(originOf: (cell) => cell)) as MapSiegeRun;

  test('loads the attackers and centres the map on the place', () {
    const siege =
        MapSiege(place: (5, 5), victory: true, attackerSprite: sprite);
    expect(siege.imagePaths, {sprite});
    expect(siege.focus, (5, 5));
  });

  test('a repelled siege raises the shield; a lost one never does', () {
    expect(runOf(victory: true).shieldAt(timeline.impact), greaterThan(0.9));
    expect(runOf(victory: false).shieldAt(timeline.impact), 0);
  });

  test('a lost siege shakes the map as the attackers reach the place', () {
    final lost = runOf(victory: false), won = runOf(victory: true);
    const after = Duration(milliseconds: 40);
    expect(lost.shakeAt(timeline.impact + after), isNot(Offset.zero));
    expect(lost.shakeAt(Duration.zero), Offset.zero);
    expect(lost.shakeAt(lost.duration), Offset.zero);
    expect(won.shakeAt(timeline.impact + after), Offset.zero);
  });

  test('lasts its timeline', () {
    expect(runOf(victory: true).duration, timeline.total);
  });

  test('paints every moment of a repelled and of a lost siege', () {
    for (final victory in [true, false]) {
      final run = runOf(victory: victory);
      for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
        final recorder = ui.PictureRecorder();
        run.paint(Canvas(recorder), Duration(milliseconds: ms));
        recorder.endRecording().dispose();
      }
    }
  });
}
