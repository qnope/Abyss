import 'package:flutter/painting.dart';

import '../../map_projection.dart';
import 'siege_geometry.dart';

/// Draws what lies on the floor around a besieged place: rings and discs
/// centred on it, placed on the flat map and laid on the floor by the
/// projection, so that a circle shows as an ellipse.
///
/// Its paints are made once and reused for every frame.
class SiegeFloor {
  /// Width of a ring on the flat map.
  static const ringWidth = 3.0;

  final SiegeGeometry geometry;

  final _fill = Paint();
  final _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = ringWidth;

  SiegeFloor(this.geometry);

  /// Starts drawing on the floor of [canvas], until [end].
  void begin(Canvas canvas) => canvas
    ..save()
    ..transform(MapProjection.isometric);

  /// Stops drawing on the floor of [canvas].
  void end(Canvas canvas) => canvas.restore();

  /// A ring [scale] times the place's radius, in [color] at [opacity].
  void ring(Canvas canvas, double scale, Color color, double opacity) {
    if (opacity <= 0) return;
    _line.color = color.withValues(alpha: opacity);
    canvas.drawCircle(geometry.center, geometry.radius * scale, _line);
  }

  /// A disc [scale] times the place's radius, in [color] at [opacity].
  void disc(Canvas canvas, double scale, Color color, double opacity) {
    if (opacity <= 0) return;
    _fill.color = color.withValues(alpha: opacity);
    canvas.drawCircle(geometry.center, geometry.radius * scale, _fill);
  }
}
