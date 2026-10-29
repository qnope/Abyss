import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'map_effect.dart';

/// Paints a [MapEffectRun] over the map as its [progress] runs from 0 to
/// 1. Never catches a tap, so the map below still receives them.
class MapEffectPainter extends CustomPainter {
  final MapEffectRun run;
  final Animation<double> progress;

  MapEffectPainter({required this.run, required this.progress})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) =>
      run.paint(canvas, run.duration * progress.value);

  @override
  bool shouldRepaint(MapEffectPainter oldDelegate) =>
      oldDelegate.run != run || oldDelegate.progress != progress;

  @override
  bool? hitTest(Offset position) => false;
}

/// Paints what a [MapEffectRun] lays on the floor, under the contents
/// standing on the map, as its [progress] runs from 0 to 1. Never catches
/// a tap.
class MapEffectFloorPainter extends CustomPainter {
  final MapEffectRun run;
  final Animation<double> progress;

  MapEffectFloorPainter({required this.run, required this.progress})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) =>
      run.paintFloor(canvas, run.duration * progress.value);

  @override
  bool shouldRepaint(MapEffectFloorPainter oldDelegate) =>
      oldDelegate.run != run || oldDelegate.progress != progress;

  @override
  bool? hitTest(Offset position) => false;
}
