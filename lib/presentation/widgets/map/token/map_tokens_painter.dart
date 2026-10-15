import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'map_token_drawer.dart';
import 'map_token_trip.dart';

/// Draws round tokens over the map, each where its [MapTokenTrip] says.
///
/// Repaints only while a token swims: tokens at rest are painted once,
/// then again only when the tokens or their [image] change. Never
/// catches a tap, so the map below still receives them.
class MapTokensPainter extends CustomPainter {
  final List<MapTokenTrip> trips;

  /// Bitmap shown in every token, or `null` while it loads.
  final ui.Image? image;

  final MapTokenDrawer _drawer = MapTokenDrawer();

  MapTokensPainter({required this.trips, this.image})
      : super(repaint: _swimsOf(trips));

  static Listenable? _swimsOf(List<MapTokenTrip> trips) {
    final swims = [
      for (final trip in trips)
        if (trip.progress case final progress?) progress,
    ];
    return swims.isEmpty ? null : Listenable.merge(swims);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final trip in trips) {
      _drawer.draw(canvas, trip.rect, image);
    }
  }

  @override
  bool shouldRepaint(MapTokensPainter oldDelegate) =>
      oldDelegate.image != image || !listEquals(oldDelegate.trips, trips);

  @override
  bool? hitTest(Offset position) => false;
}
