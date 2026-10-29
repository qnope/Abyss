import 'package:abyss/presentation/widgets/map/effects/story/fog_lift_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/map_content_spot.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fog_lift_stage.dart';
import 'recording_canvas.dart';

void main() {
  const tile = 'assets/icons/terrain/plain_iso_1.svg';
  const wreck = 'assets/icons/map_content/wreck.svg';
  const beacon = MapFogLift(
    cells: {(3, 3): tile, (4, 3): tile},
    beacons: {(3, 3): wreck, (4, 3): wreck},
    focus: (3, 3),
  );
  final back = MapContentSpot.at((3, 3)), front = MapContentSpot.at((4, 3));

  test('a wreck seen through the fog is loaded before the lift starts', () {
    expect(beacon.imagePaths, contains(wreck));
  });

  testWidgets('a wreck stands above the fog as the standing layer draws '
      'it, fading with it', (tester) async {
    final image = await tester.runAsync(() => createTestImage());
    final run = beacon.stage(FogLiftStage(image!)) as FogLiftRun;
    final canvas = RecordingCanvas();
    run.paint(canvas, Duration.zero);
    final fog = canvas.order.indexOf(canvas.paths.last.$1.getBounds());
    final pool = canvas.order.indexOf(back.glow);
    final shadow = canvas.order.indexOf(back.shadow);
    final body = canvas.order.indexOf(back.area);
    expect(pool, greaterThan(fog));
    expect(shadow, greaterThan(pool));
    expect(body, greaterThan(shadow));
    expect(canvas.order.indexOf(front.area), greaterThan(body),
        reason: 'back to front');
    expect(canvas.images.firstWhere((i) => i.$1 == back.area).$2.a, 1);
    final late = RecordingCanvas();
    final at = run.duration - const Duration(milliseconds: 100);
    run.paint(late, at);
    final alpha = late.images.firstWhere((i) => i.$1 == back.area).$2.a;
    expect(alpha, closeTo(run.opacityAt(at), 0.01));
  });
}
