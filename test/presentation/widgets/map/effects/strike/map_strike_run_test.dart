import 'dart:ui' as ui;

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_timeline.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strike_test_data.dart';

void main() {
  const lair = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 1);

  MapEffectRun runOf({bool victory = true}) => MapStrike.of(
        target: (5, 5),
        lair: lair,
        result: strikeResult(victory: victory, taken: const [2, 0]),
      ).stage(MapStage(originOf: (_) => (0, 5)));

  test('lasts the swim from the origin, two lunges and the outcome', () {
    final swim = MapTokenTrip.durationOf((0, 5), (4, 5));
    expect(runOf().duration,
        StrikeTimeline(swim: swim, hits: 2).total);
  });

  test('shakes the map only right after each hit', () {
    final swim = MapTokenTrip.durationOf((0, 5), (4, 5));
    final timeline = StrikeTimeline(swim: swim, hits: 2);
    final run = runOf();
    expect(run.shakeAt(swim), Offset.zero);
    expect(run.shakeAt(timeline.hitAt(0) + const Duration(milliseconds: 40)),
        isNot(Offset.zero));
    expect(run.shakeAt(timeline.total), Offset.zero);
  });

  test('paints every moment of a victory and of a defeat', () {
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
