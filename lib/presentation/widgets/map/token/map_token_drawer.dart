import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../../theme/abyss_colors.dart';

/// Draws a round token on the map: a unit's bitmap clipped in a disc of
/// deep water, circled by a thin bioluminescent ring.
///
/// Its paints are made once and reused for every token it draws.
class MapTokenDrawer {
  /// Width of the ring, in logical pixels.
  static const ringWidth = 1.5;

  final _water = Paint();
  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = ringWidth;

  /// Draws a token filling [rect], showing [image] once it is loaded, at
  /// [opacity] (set on the paints, never through a layer), circled by
  /// [ring].
  void draw(Canvas canvas, Rect rect, ui.Image? image,
      {double opacity = 1, Color ring = AbyssColors.biolumCyan}) {
    if (opacity <= 0) return;
    _water.color = AbyssColors.deepNavy.withValues(alpha: opacity);
    _image.color = Color.fromRGBO(0, 0, 0, opacity);
    _ring.color = ring.withValues(alpha: ring.a * opacity);
    final radius = rect.shortestSide / 2;
    final center = rect.center;
    canvas.drawCircle(center, radius, _water);
    if (image != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      final src = Rect.fromLTWH(
          0, 0, image.width.toDouble(), image.height.toDouble());
      canvas.drawImageRect(image, src, rect, _image);
      canvas.restore();
    }
    canvas.drawCircle(center, radius - ringWidth / 2, _ring);
  }
}
