import 'package:flutter/widgets.dart';

import '../ambience/ambience_clock.dart';
import '../backdrop/marine_snow_field.dart';
import 'map_snow_painter.dart';

/// A light marine snow filling its box, driven by an ambience [clock].
///
/// Lays over the screen, not the map: it neither zooms nor pans, never
/// takes a tap and repaints within its own boundary.
class MapSnowLayer extends StatelessWidget {
  final AmbienceClock clock;

  static final _field = MarineSnowField(density: MapSnowPainter.density);

  const MapSnowLayer({super.key, required this.clock});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: MapSnowPainter(clock: clock, field: _field),
          ),
        ),
      );
}
