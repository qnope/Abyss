import 'package:flutter/material.dart';

import '../ambience/ambience_clock.dart';
import '../ambience/ambience_clock_scope.dart';
import 'map_snow_layer.dart';

/// Builds the layers of a map from the ambience [clock] they share and
/// the [viewport] size the map is seen through.
typedef MapLayersBuilder =
    Widget Function(BuildContext context, AmbienceClock clock, Size viewport);

/// A pannable, zoomable view of a map under a light marine snow.
///
/// Owns the ambience clock of the map: the layers built by [builder]
/// (moved by [controller], tapped through [onTapUp]) and the snow lying
/// over the screen all share it.
class MapViewport extends StatelessWidget {
  final TransformationController controller;
  final double minScale;
  final double maxScale;
  final GestureTapUpCallback? onTapUp;
  final MapLayersBuilder builder;

  const MapViewport({
    super.key,
    required this.controller,
    required this.minScale,
    required this.maxScale,
    required this.builder,
    this.onTapUp,
  });

  @override
  Widget build(BuildContext context) => AmbienceClockScope(
        builder: (context, clock) => LayoutBuilder(
          builder: (context, constraints) => Stack(
            fit: StackFit.passthrough,
            children: [
              InteractiveViewer(
                constrained: false,
                transformationController: controller,
                minScale: minScale,
                maxScale: maxScale,
                child: GestureDetector(
                  onTapUp: onTapUp,
                  child: builder(context, clock, constraints.biggest),
                ),
              ),
              Positioned.fill(child: MapSnowLayer(clock: clock)),
            ],
          ),
        ),
      );
}
