import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// How a map's box (its content) fits the viewport it is seen through,
/// zoomed out to show the whole map floating over the abyss.
///
/// An InteractiveViewer never zooms out past the scale where its content
/// and boundary margin still cover the viewport: [abyssAround] gives the
/// margin letting the view zoom out from its current scale, so it is
/// rebuilt as the scale changes.
abstract final class MapViewFit {
  /// Share of the viewport the whole map fills, along its tighter axis,
  /// when zoomed out the most.
  static const overviewFill = 0.88;

  /// How far out a gesture may zoom from the current scale before the
  /// margin is given again, at the next frame.
  static const zoomOutStep = 0.8;

  /// The scale at which the whole [content] shows in the middle of the
  /// [viewport], the abyss around it; 1 for an empty content.
  static double overviewScale(Size viewport, Size content) {
    if (content.isEmpty) return 1;
    return overviewFill *
        math.min(viewport.width / content.width,
            viewport.height / content.height);
  }

  /// The margin around [content] letting a view at [scale] zoom out by a
  /// [zoomOutStep], down to the [overviewScale], the map in the middle:
  /// none while the map covers the viewport even zoomed out a step, so
  /// the map then pans edge to edge as before.
  static EdgeInsets abyssAround(Size viewport, Size content, double scale) {
    if (content.isEmpty) return EdgeInsets.zero;
    final floor = math.max(
        overviewScale(viewport, content), zoomOutStep * scale);
    double side(double view, double box) =>
        math.max(0, (view / floor - box) / 2);
    return EdgeInsets.symmetric(
      horizontal: side(viewport.width, content.width),
      vertical: side(viewport.height, content.height),
    );
  }
}
