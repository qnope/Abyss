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

/// The box of what a [viewport] shows past the convex [shape] (its
/// vertices in turn, in the content's coordinates) seen through
/// [transform], the shape's edges taken [margin] logical pixels in:
/// empty when the shape covers it all, what lies behind the shape
/// showing nowhere else.
Rect uncoveredArea(
  List<Offset> shape,
  Matrix4 transform,
  Size viewport, {
  double margin = 0,
}) {
  final screen = Offset.zero & viewport;
  final m = transform.storage;
  final (scale, shift) = (m[0], Offset(m[12], m[13]));
  if (shape.length < 3 || scale <= 0) return screen;
  final points = [for (final point in shape) point * scale + shift];
  var winding = 0.0;
  for (var i = 0; i < points.length; i++) {
    final (a, b) = (points[i], points[(i + 1) % points.length]);
    winding += a.dx * b.dy - b.dx * a.dy;
  }
  final corners = [
    screen.topLeft, screen.topRight, screen.bottomRight, screen.bottomLeft,
  ];
  Rect? area;
  // The shape is where every edge has it on its inner side: what shows
  // lies on the outer side of one edge at least.
  for (var i = 0; i < points.length; i++) {
    final (a, b) = (points[i], points[(i + 1) % points.length]);
    final length = (b - a).distance;
    if (length == 0) continue;
    // How far outside the edge taken in a point lies.
    double past(Offset p) =>
        margin -
        ((b.dx - a.dx) * (p.dy - a.dy) - (b.dy - a.dy) * (p.dx - a.dx)) *
            winding.sign /
            length;
    final pasts = [for (final corner in corners) past(corner)];
    if (pasts.every((g) => g <= 0)) continue;
    // The screen clipped to that outer side: its corners there, and where
    // its sides cross the edge.
    for (var j = 0; j < corners.length; j++) {
      final k = (j + 1) % corners.length;
      final (p, q, gp, gq) = (corners[j], corners[k], pasts[j], pasts[k]);
      final outside = [
        if (gp >= 0) p,
        if (gp * gq < 0) p + (q - p) * (gp / (gp - gq)),
      ];
      for (final point in outside) {
        final dot = Rect.fromPoints(point, point);
        area = area?.expandToInclude(dot) ?? dot;
      }
    }
  }
  return area ?? Rect.zero;
}
