import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/fog_lift_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fog_lift_stage.dart';
import 'recording_canvas.dart';

void main() {
  const tile = 'assets/icons/terrain/plain_iso_1.svg';
  const lift = MapFogLift(
    cells: {(3, 3): tile, (4, 3): tile},
    beacons: {(4, 3)},
    focus: (3, 3),
  );

  testWidgets('leaves every content to the standing layer, a wreck seen '
      'through the fog included', (tester) async {
    final image = await tester.runAsync(() => createTestImage());
    final run = lift.stage(FogLiftStage(image!)) as FogLiftRun;
    final canvas = RecordingCanvas();
    run
      ..paintFloor(canvas, Duration.zero)
      ..paint(canvas, Duration.zero);
    for (final cell in lift.cells.keys) {
      final spot = MapContentSpot.at(cell);
      for (final box in [spot.area, spot.glow, spot.shadow]) {
        expect(canvas.order, isNot(contains(box)), reason: '$cell');
      }
    }
  });

  test('fades in the contents of the cells seen as the fog lifts, a wreck '
      'seen through it staying whole', () {
    final run = lift.stage(MapStage(originOf: (cell) => cell)) as FogLiftRun;
    expect(run.fadedCells, {(3, 3)});
    expect(run.contentOpacityAt(Duration.zero), 0);
    expect(run.contentOpacityAt(FogLiftRun.hold), 0);
    for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
      final at = Duration(milliseconds: ms);
      expect(run.contentOpacityAt(at), closeTo(1 - run.opacityAt(at), 1e-9));
    }
    expect(run.contentOpacityAt(run.duration), 1);
  });
}
