import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_motion.dart';
import '../backdrop/marine_snow_field.dart';
import '../backdrop/trench/parallax_drift.dart';

/// A light marine snow drifting over the map, in screen space.
///
/// Lighter than the menu's: fewer flakes, no light rays, one halo per
/// flake. Driven by the seconds of a shared ambience [clock], it loops
/// over [AbyssMotion.ambientLoop]. Nearer than the map, it slides
/// [panRate] times as far as the map's [content] when [transform] pans
/// it, wrapping around the box. Buffers and paints are made once, so a
/// frame allocates nothing; it never takes a tap.
class MapSnowPainter extends CustomPainter {
  /// Share of the menu's flakes falling over the map.
  static const density = 0.4;

  /// How far the snow slides for each pixel the map slides.
  static const panRate = 1.2;

  /// Seconds of the shared ambience clock.
  final ValueListenable<double> clock;
  final MarineSnowField field;

  /// The pan and zoom of the map, if the snow follows it.
  final ValueListenable<Matrix4>? transform;

  /// Size of the map's box, to find its centre (see [contentDrift]).
  final Size content;

  final List<Float32List> _points;
  final List<Paint> _halos;
  final List<Paint> _cores;

  static const _haloScale = 2.6;

  MapSnowPainter({
    required this.clock,
    required this.field,
    this.transform,
    this.content = Size.zero,
  })  : _points = [for (final l in field.layers) Float32List(2 * l.count)],
        _halos = [
          for (final l in field.layers)
            _dotPaint(l.halo, l.radius * 2 * _haloScale),
        ],
        _cores = [
          for (final l in field.layers) _dotPaint(l.core, l.radius * 2),
        ],
        super(repaint: transform == null
            ? clock
            : Listenable.merge([clock, transform]));

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
      _slide(points, size);
      canvas.drawRawPoints(ui.PointMode.points, points, _halos[i]);
      canvas.drawRawPoints(ui.PointMode.points, points, _cores[i]);
    }
  }

  /// Slides the flakes in [points] as the map pans, wrapping them around
  /// the box as they wrap when they rise.
  void _slide(Float32List points, Size size) {
    final m = transform?.value.storage;
    if (m == null) return;
    final dx = panRate * driftAlong(m[12], m[0], content.width, size.width);
    final dy = panRate * driftAlong(m[13], m[5], content.height, size.height);
    const margin = MarineSnowField.margin;
    final height = size.height + 2 * margin;
    for (var i = 0; i < points.length; i += 2) {
      points[i] = (points[i] + dx) % size.width;
      points[i + 1] = (points[i + 1] + dy + margin) % height - margin;
    }
  }

  @override
  bool shouldRepaint(MapSnowPainter oldDelegate) =>
      oldDelegate.clock != clock ||
      oldDelegate.field != field ||
      oldDelegate.transform != transform ||
      oldDelegate.content != content;

  @override
  bool? hitTest(Offset position) => false;
}
