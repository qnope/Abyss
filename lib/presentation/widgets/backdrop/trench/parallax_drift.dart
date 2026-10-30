import 'package:flutter/widgets.dart';

/// How far the centre of a [content] box, shown through [transform] (a
/// pan and zoom, as an InteractiveViewer's), lies from the centre of the
/// [viewport], in screen pixels: what parallax layers follow, each at its
/// own rate.
///
/// Nothing while the content is centred, as when a map is zoomed out
/// the most: the layers then show as designed.
Offset contentDrift(Matrix4 transform, Size content, Size viewport) {
  final m = transform.storage;
  return Offset(
    driftAlong(m[12], m[0], content.width, viewport.width),
    driftAlong(m[13], m[5], content.height, viewport.height),
  );
}

/// [contentDrift] along one axis, from the [translation] and [scale] of
/// the transform: lets a painter follow the drift without allocating.
double driftAlong(
  double translation,
  double scale,
  double content,
  double viewport,
) =>
    translation + scale * content / 2 - viewport / 2;

/// Where a parallax layer two tiles of [period] wide and [overscan]
/// taller on each side than its viewport is drawn, following a [drift]
/// at its [rate]: wrapped sideways within a period, so the two tiles
/// always cover the viewport, and stopped up or down at its overscan.
Offset parallaxShift(
  Offset drift, {
  required double rate,
  required double period,
  required double overscan,
}) {
  final dx = period > 0 ? (rate * drift.dx) % period - period : 0.0;
  return Offset(dx, (rate * drift.dy).clamp(-overscan, overscan));
}
