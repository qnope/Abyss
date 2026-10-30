import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../ambience/ambience_clock.dart';
import '../backdrop/marine_snow_field.dart';
import 'map_snow_painter.dart';

/// A light marine snow filling its box, driven by an ambience [clock].
///
/// Lays over the screen, not the map: it never zooms, only slides a
/// little faster than the map's [content] as [transform] pans it, if
/// given (see [MapSnowPainter]). Never takes a tap and repaints within
/// its own boundary.
class MapSnowLayer extends StatelessWidget {
  final AmbienceClock clock;

  /// The pan and zoom of the map the snow lies over.
  final ValueListenable<Matrix4>? transform;

  /// Size of the map's box.
  final Size content;

  static final _field = MarineSnowField(density: MapSnowPainter.density);

  const MapSnowLayer({
    super.key,
    required this.clock,
    this.transform,
    this.content = Size.zero,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: MapSnowPainter(clock: clock, field: _field,
                transform: transform, content: content),
          ),
        ),
      );
}
