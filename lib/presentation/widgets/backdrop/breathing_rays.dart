import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_colors.dart';

/// Faint shafts of light falling from the surface, slowly brightening and
/// dimming over the illustrated rays of the art.
///
/// Shapes and shader are built once per size; each frame only picks one
/// of a few precomputed colours whose alpha modulates the shader, so
/// painting allocates nothing.
class BreathingRays {
  /// Strongest added light, as an opacity.
  static const maxAlpha = 0.07;

  /// Breaths per animation cycle: whole, so the cycle loops seamlessly.
  static const breaths = 4;

  /// Horizontal centre and half width of each shaft where it reaches the
  /// bottom of the glow, as fractions of the box width.
  static const _shafts = [
    (0.2, 0.05),
    (0.42, 0.035),
    (0.6, 0.06),
    (0.82, 0.04),
  ];

  static const _levels = 24;
  static final List<Color> _alphas = [
    for (var i = 0; i < _levels; i++)
      AbyssColors.daylight.withValues(alpha: maxAlpha * i / (_levels - 1)),
  ];

  final List<Paint> _paints = [for (final _ in _shafts) Paint()];
  final List<Path> _paths = [for (final _ in _shafts) Path()];
  Size _size = Size.zero;

  void paint(Canvas canvas, Size size, double t) {
    if (size.isEmpty) return;
    if (size != _size) _layout(size);
    for (var i = 0; i < _shafts.length; i++) {
      final phase = 2 * math.pi * (t * breaths + i / _shafts.length);
      final level = (0.5 + 0.5 * math.sin(phase)) * (_levels - 1);
      _paints[i].color = _alphas[level.round()];
      canvas.drawPath(_paths[i], _paints[i]);
    }
  }

  void _layout(Size size) {
    _size = size;
    final bottom = size.height * 0.7;
    final shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, bottom),
      [
        AbyssColors.pearlWhite,
        AbyssColors.biolumCyan.withValues(alpha: 0.4),
        AbyssColors.biolumCyan.withValues(alpha: 0),
      ],
      const [0, 0.45, 1],
    );
    // Shafts fan out from a light source above the top centre.
    final source = Offset(size.width * 0.48, -size.height * 0.35);
    for (var i = 0; i < _shafts.length; i++) {
      final (centre, half) = _shafts[i];
      final left = Offset(size.width * (centre - half), bottom);
      final right = Offset(size.width * (centre + half), bottom);
      _paths[i]
        ..reset()
        ..moveTo(_atTop(source, left), 0)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(_atTop(source, right), 0)
        ..close();
      _paints[i].shader = shader;
    }
  }

  /// Abscissa where the line from [source] to [point] crosses the top.
  static double _atTop(Offset source, Offset point) =>
      source.dx +
      (point.dx - source.dx) * (-source.dy) / (point.dy - source.dy);
}
