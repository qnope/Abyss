import 'dart:ui' as ui;

import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/fog_lift_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'recording_canvas.dart';

const _terrain = 'assets/icons/terrain/plain.svg';

int _rgb(Color color) => color.toARGB32() & 0xFFFFFF;

void main() {
  const lift = MapFogLift(
    cells: {(2, 3): _terrain, (3, 3): _terrain, (7, 1): _terrain},
    scouts: {(2, 3)},
    focus: (2, 3),
  );
  final run = lift.stage(MapStage(originOf: (cell) => cell)) as FogLiftRun;

  Rect cellRect((int, int) c) =>
      Rect.fromLTWH(c.$1 * cellSize, c.$2 * cellSize, cellSize, cellSize);

  /// The rectangles of fog drawn [elapsed] into the lift, by opacity.
  List<(Rect, Color)> fogAt(Duration elapsed) {
    final canvas = RecordingCanvas();
    run.paint(canvas, elapsed);
    return [
      for (final (rect, color) in canvas.rects)
        if (_rgb(color) == _rgb(AbyssColors.abyssBlack) && color.a < 1)
          (rect, color),
    ];
  }

  test('starts as the fog of the still map, over exactly the seen cells', () {
    final fog = fogAt(Duration.zero);
    expect(fog.map((f) => f.$1).toSet(),
        {cellRect((2, 3)), cellRect((3, 3)), cellRect((7, 1))});
    for (final (_, color) in fog) {
      expect(color.a, closeTo(AbyssColors.fogOpacity, 0.01));
    }
  });

  test('its opacity runs from full to nothing', () {
    expect(run.opacityAt(Duration.zero), 1);
    var last = 1.0;
    for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
      final opacity = run.opacityAt(Duration(milliseconds: ms));
      expect(opacity, lessThanOrEqualTo(last));
      last = opacity;
    }
    expect(run.opacityAt(run.duration), 0);
    expect(fogAt(run.duration), isEmpty);
  });

  test('never shakes the map', () {
    expect(run.shakeAt(run.duration ~/ 2), Offset.zero);
  });

  test('loads the terrains and the scout before it starts', () {
    expect(lift.imagePaths, contains(_terrain));
    expect(lift.imagePaths, hasLength(2));
  });

  group('a wreck seen through the fog', () {
    const wreck = 'assets/icons/map_content/wreck.svg';
    const beacon = MapFogLift(
      cells: {(3, 3): _terrain},
      beacons: {(3, 3): wreck},
      focus: (3, 3),
    );

    test('is loaded before the lift starts', () {
      expect(beacon.imagePaths, contains(wreck));
    });

    testWidgets('stays above the fog, fading with it', (tester) async {
      final image = await tester.runAsync(() => createTestImage());
      final run = beacon.stage(_Stage(image!)) as FogLiftRun;
      final body = cellRect((3, 3))
          .deflate((cellSize - MapContentDrawer.contentSize) / 2);
      final canvas = RecordingCanvas();
      run.paint(canvas, Duration.zero);
      final fog = canvas.order.lastIndexOf(cellRect((3, 3)));
      expect(canvas.order.indexOf(body), greaterThan(fog));
      expect(canvas.images.where((i) => i.$1 == body).single.$2.a, 1);
      final late = RecordingCanvas();
      final at = run.duration - const Duration(milliseconds: 100);
      run.paint(late, at);
      final alpha = late.images.where((i) => i.$1 == body).single.$2.a;
      expect(alpha, closeTo(run.opacityAt(at), 0.01));
    });
  });

  test('paints every moment on a real canvas', () {
    for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
      final recorder = ui.PictureRecorder();
      run.paint(Canvas(recorder), Duration(milliseconds: ms));
      recorder.endRecording().dispose();
    }
  });
}

/// A stage where every bitmap, glows included, is [image].
class _Stage extends MapStage {
  final ui.Image bitmap;

  _Stage(this.bitmap) : super(originOf: (cell) => cell);

  @override
  ui.Image? image(String path) => bitmap;

  @override
  ui.Image? glow(MapGlow glow) => bitmap;
}
