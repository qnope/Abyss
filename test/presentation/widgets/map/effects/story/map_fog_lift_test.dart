import 'dart:ui' as ui;

import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/fog_lift_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fog_lift_stage.dart';
import 'recording_canvas.dart';

const _tile = 'assets/icons/terrain/plain_iso_1.svg';

int _rgb(Color color) => color.toARGB32() & 0xFFFFFF;

void main() {
  const seen = [(2, 3), (3, 3), (7, 1)];
  const lift = MapFogLift(
    cells: {(2, 3): _tile, (3, 3): _tile, (7, 1): _tile},
    scouts: {(2, 3)},
    focus: (2, 3),
  );
  final run = lift.stage(MapStage(originOf: (cell) => cell)) as FogLiftRun;

  /// The floor part of [run] painted [elapsed] into it.
  RecordingCanvas floorAt(FogLiftRun run, Duration elapsed) {
    final canvas = RecordingCanvas();
    run.paintFloor(canvas, elapsed);
    return canvas;
  }

  /// The paths of fog drawn [elapsed] into the lift, with their colour.
  List<(Path, Color)> fogAt(Duration elapsed) => [
        for (final (path, color, _) in floorAt(run, elapsed).paths)
          if (_rgb(color) == _rgb(AbyssColors.abyssBlack) && color.a < 1)
            (path, color),
      ];

  test('starts as the fog of the still map, over the seen diamonds, on '
      'the floor', () {
    final (fog, color) = fogAt(Duration.zero).single;
    expect(color.a, closeTo(AbyssColors.fogOpacity, 0.01));
    for (final cell in seen) {
      expect(fog.contains(MapProjection.centreOf(cell)), isTrue);
    }
    expect(fog.contains(MapProjection.centreOf((5, 5))), isFalse);
    expect(fog.contains(MapProjection.tileRectOf((2, 3)).topLeft), isFalse);
  });

  testWidgets('lays the floor tile of each cell on its diamond, under the '
      'fog', (tester) async {
    final image = await tester.runAsync(() => createTestImage());
    final canvas = floorAt(lift.stage(FogLiftStage(image!)) as FogLiftRun,
        Duration.zero);
    final fog =
        canvas.order.lastIndexOf(fogAt(Duration.zero).single.$1.getBounds());
    for (final cell in seen) {
      final tile = canvas.order.indexOf(MapPainter.tileOf(cell));
      expect(tile, inExclusiveRange(-1, fog));
    }
  });

  test("outlines a scout's target in a cyan diamond on the floor, the "
      'scout waiting on its edge over the map', () {
    final canvas = floorAt(run, Duration.zero);
    final (mark, _, _) = canvas.paths.singleWhere((p) =>
        p.$3 == PaintingStyle.stroke &&
        _rgb(p.$2) == _rgb(AbyssColors.biolumCyan));
    expect(mark.contains(MapProjection.centreOf((2, 3))), isTrue);
    expect(mark.contains(MapProjection.centreOf((3, 3))), isFalse);
    expect(canvas.discs, isEmpty);
    final over = RecordingCanvas();
    run.paint(over, Duration.zero);
    expect(over.paths, isEmpty, reason: 'no floor drawn over the map');
    expect(over.discs, [
      MapProjection.toScreen(MapTokenTrip.restingRect((2, 3)).center),
    ]);
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
    expect(lift.imagePaths, contains(_tile));
    expect(lift.imagePaths, hasLength(2));
  });

  test('paints every moment on a real canvas', () {
    for (var ms = 0; ms <= run.duration.inMilliseconds; ms += 50) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      run.paintFloor(canvas, Duration(milliseconds: ms));
      run.paint(canvas, Duration(milliseconds: ms));
      recorder.endRecording().dispose();
    }
  });
}
