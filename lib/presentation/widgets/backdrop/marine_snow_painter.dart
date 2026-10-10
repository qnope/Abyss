import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'breathing_rays.dart';
import 'marine_snow_field.dart';

/// Paints rising marine snow and breathing light rays.
///
/// Repaints on every tick of [animation] without rebuilding any widget.
/// Each flake layer is three batched point draws from a reused buffer
/// (two halo steps fading outwards, then a bright core): a frame
/// allocates nothing.
class MarineSnowPainter extends CustomPainter {
  /// Progress through one seamless cycle, from 0 to 1.
  final Animation<double> animation;
  final MarineSnowField field;

  final BreathingRays _rays = BreathingRays();
  final List<Float32List> _points;
  final List<Paint> _outerHalos;
  final List<Paint> _innerHalos;
  final List<Paint> _cores;

  /// Halo diameters as multiples of the core's.
  static const outerHalo = 3.6;
  static const innerHalo = 2.2;

  MarineSnowPainter({required this.animation, required this.field})
    : _points = [for (final l in field.layers) Float32List(2 * l.count)],
      _outerHalos = [
        for (final l in field.layers)
          _dotPaint(
            l.halo.withValues(alpha: l.halo.a / 2),
            l.radius * 2 * outerHalo,
          ),
      ],
      _innerHalos = [
        for (final l in field.layers)
          _dotPaint(l.halo, l.radius * 2 * innerHalo),
      ],
      _cores = [for (final l in field.layers) _dotPaint(l.core, l.radius * 2)],
      super(repaint: animation);

  static Paint _dotPaint(Color color, double diameter) =>
      Paint()
        ..color = color
        ..strokeWidth = diameter
        ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = animation.value;
    _rays.paint(canvas, size, t);
    for (var i = 0; i < field.layers.length; i++) {
      final points = _points[i];
      field.writePositions(field.layers[i], t, size, points);
      canvas.drawRawPoints(ui.PointMode.points, points, _outerHalos[i]);
      canvas.drawRawPoints(ui.PointMode.points, points, _innerHalos[i]);
      canvas.drawRawPoints(ui.PointMode.points, points, _cores[i]);
    }
  }

  @override
  bool shouldRepaint(MarineSnowPainter oldDelegate) =>
      oldDelegate.field != field || oldDelegate.animation != animation;

  @override
  bool? hitTest(Offset position) => false;
}
