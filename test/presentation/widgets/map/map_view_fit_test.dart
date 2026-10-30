import 'dart:math' as math;

import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const phone = Size(390, 600);
  final map = MapProjection.sizeOf(20, 20);

  /// The smallest scale an InteractiveViewer allows within [margin]: the
  /// map and its margin must cover the viewport.
  double floorOf(EdgeInsets margin) => math.max(
      phone.width / (map.width + margin.horizontal),
      phone.height / (map.height + margin.vertical));

  test('zoomed out the most, the whole map shows with the abyss around', () {
    final scale = MapViewFit.overviewScale(phone, map);
    final shown = map * scale;
    expect(shown.width, lessThan(phone.width));
    expect(shown.height, lessThan(phone.height));
    expect(math.max(shown.width / phone.width, shown.height / phone.height),
        closeTo(MapViewFit.overviewFill, 1e-9));
    expect(MapViewFit.overviewScale(phone, Size.zero), 1);
  });

  test('zoomed out the most, the map stays in the middle', () {
    final scale = MapViewFit.overviewScale(phone, map);
    final margin = MapViewFit.abyssAround(phone, map, scale);
    expect(margin.left, margin.right);
    expect(margin.top, margin.bottom);
    expect(floorOf(margin), closeTo(scale, 1e-9));
    // The viewport is the map and its margin: it cannot pan.
    expect(map.width + margin.horizontal, closeTo(phone.width / scale, 1e-6));
    expect(map.height + margin.vertical, closeTo(phone.height / scale, 1e-6));
  });

  test('no abyss shows around a map filling the screen', () {
    final scale = phone.width / (4.5 * MapProjection.tileWidth);
    expect(MapViewFit.abyssAround(phone, map, scale), EdgeInsets.zero);
  });

  test('any view may zoom out a step at a time down to the overview', () {
    final overview = MapViewFit.overviewScale(phone, map);
    for (final scale in [overview, 0.2, 0.3, 0.5, 0.7, 1.0, 2.0]) {
      final margin = MapViewFit.abyssAround(phone, map, scale);
      expect(margin.isNonNegative, isTrue);
      expect(floorOf(margin),
          lessThanOrEqualTo(math.max(overview, MapViewFit.zoomOutStep * scale) +
              1e-9),
          reason: 'at $scale');
    }
  });
}
