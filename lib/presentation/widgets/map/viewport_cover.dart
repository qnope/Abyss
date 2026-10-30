import 'package:flutter/widgets.dart';

/// Whether the convex [shape] (its vertices in turn, in the content's
/// coordinates), seen through [transform] (a pan and zoom, as an
/// InteractiveViewer's), covers the whole of a [viewport], [margin]
/// logical pixels past its edges included: what lies behind it then
/// never shows.
bool coversViewport(
  List<Offset> shape,
  Matrix4 transform,
  Size viewport, {
  double margin = 0,
}) {
  if (shape.length < 3) return false;
  final m = transform.storage;
  final (scale, shift) = (m[0], Offset(m[12], m[13]));
  if (scale <= 0) return false;
  final screen = (Offset.zero & viewport).inflate(margin);
  final corners = [
    screen.topLeft, screen.topRight, screen.bottomRight, screen.bottomLeft,
  ];
  // The side of each edge the shape's inside lies on, by its winding.
  var winding = 0.0;
  for (var i = 0; i < shape.length; i++) {
    final (a, b) = (shape[i], shape[(i + 1) % shape.length]);
    winding += a.dx * b.dy - b.dx * a.dy;
  }
  for (final corner in corners) {
    final point = (corner - shift) / scale;
    for (var i = 0; i < shape.length; i++) {
      final (a, b) = (shape[i], shape[(i + 1) % shape.length]);
      final side = (b.dx - a.dx) * (point.dy - a.dy) -
          (b.dy - a.dy) * (point.dx - a.dx);
      if (side * winding < 0) return false;
    }
  }
  return true;
}
