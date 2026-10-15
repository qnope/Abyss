import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_motion.dart';
import '../backdrop/marine_snow_field.dart';

/// A light marine snow drifting over the map, in screen space.
///
/// Lighter than the menu's: fewer flakes, no light rays, one halo per
/// flake. Driven by the seconds of a shared ambience [clock], it loops
/// over [AbyssMotion.ambientLoop]. Buffers and paints are made once, so
/// a frame allocates nothing; it never takes a tap.
class MapSnowPainter extends CustomPainter {
  /// Share of the menu's flakes falling over the map.
  static const density = 0.4;

  /// Seconds of the shared ambience clock.
  final ValueListenable<double> clock;
  final MarineSnowField field;

  final List<Float32List> _points;
  final List<Paint> _halos;
  final List<Paint> _cores;

  static const _haloScale = 2.6;

  MapSnowPainter({required this.clock, required this.field})
      : _points = [for (final l in field.layers) Float32List(2 * l.count)],
        _halos = [
          for (final l in field.layers)
            _dotPaint(l.halo, l.radius * 2 * _haloScale),
        ],
        _cores = [
          for (final l in field.layers) _dotPaint(l.core, l.radius * 2),
        ],
        super(repaint: clock);

  static Paint _dotPaint(Color color, double diameter) => Paint()
    ..color = color
    ..strokeWidth = diameter
    ..strokeCap = StrokeCap.round;

  static final double _loopSeconds =
      AbyssMotion.ambientLoop.inMicroseconds / 1e6;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = (clock.value % _loopSeconds) / _loopSeconds;
    for (var i = 0; i < field.layers.length; i++) {
      final points = _points[i];
      field.writePositions(field.layers[i], t, size, points);
      canvas.drawRawPoints(ui.PointMode.points, points, _halos[i]);
      canvas.drawRawPoints(ui.PointMode.points, points, _cores[i]);
    }
  }

  @override
  bool shouldRepaint(MapSnowPainter oldDelegate) =>
      oldDelegate.clock != clock || oldDelegate.field != field;

  @override
  bool? hitTest(Offset position) => false;
}
