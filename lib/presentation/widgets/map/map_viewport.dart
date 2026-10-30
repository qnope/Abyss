import 'package:flutter/material.dart';

import '../ambience/ambience_clock.dart';
import '../../theme/abyss_colors.dart';
import '../ambience/ambience_clock_scope.dart';
import '../backdrop/trench/depth_haze.dart';
import '../backdrop/trench/trench_backdrop.dart';
import 'map_projection.dart';
import 'map_snow_layer.dart';
import 'map_view_fit.dart';
import 'viewport_cover.dart';

/// Builds the layers of a map from the ambience [clock] they share and
/// the [viewport] size the map is seen through.
typedef MapLayersBuilder =
    Widget Function(BuildContext context, AmbienceClock clock, Size viewport);

/// A pannable, zoomable view of a map floating in a deep trench: the
/// trench's water and walls slide behind it ([TrenchBackdrop]), the haze
/// of depth and a light marine snow lie over it.
///
/// Owns the ambience clock of the map: the layers built by [builder]
/// (moved by [controller], tapped anywhere in their box through
/// [onTapUp]) and the snow lying over the screen all share it. Zooms out
/// until the whole map's box ([content]) shows in the middle of the
/// abyss (see [MapViewFit]), and in up to [maxScale]. The trench is left
/// unpainted while the map's [floor] fills the screen.
class MapViewport extends StatelessWidget {
  /// How far past the screen's edges the floor must reach to hide the
  /// trench: more than a blow shakes the map.
  static const coverMargin = 8.0;

  final TransformationController controller;

  /// Size of the map's box, as the layers built by [builder] fill it.
  final Size content;

  /// The convex part of the map's box its floor covers, if any (see
  /// [coversViewport]).
  final List<Offset>? floor;
  final double maxScale;
  final GestureTapUpCallback? onTapUp;
  final MapLayersBuilder builder;

  const MapViewport({
    super.key,
    required this.controller,
    required this.content,
    required this.maxScale,
    required this.builder,
    this.onTapUp,
    this.floor,
  });

  /// The transform showing the tile of [cell] in the middle of a
  /// [screen], on a projected map of [rows], zoomed so that
  /// [visibleTiles] tiles fit across it.
  static Matrix4 centeredOn(
    Size screen,
    (int, int) cell, {
    required int rows,
    required double visibleTiles,
  }) {
    final scale = screen.width / (visibleTiles * MapProjection.tileWidth);
    final point = MapProjection.originOf(rows) + MapProjection.centreOf(cell);
    final dx = screen.width / 2 - point.dx * scale;
    final dy = screen.height / 2 - point.dy * scale;
    // Scaled on every axis, as an InteractiveViewer zooms: it reads the
    // scale back as the largest of them.
    return Matrix4.translationValues(dx, dy, 0)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  bool _covered(Matrix4 transform, Size viewport) {
    final floor = this.floor;
    return floor != null &&
        coversViewport(floor, transform, viewport, margin: coverMargin);
  }

  @override
  Widget build(BuildContext context) => AmbienceClockScope(
        builder: (context, clock) => LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.biggest;
            final map = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onTapUp,
              child: builder(context, clock, viewport),
            );
            return ColoredBox(
              color: AbyssColors.abyssBlack,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<Matrix4>(
                      valueListenable: controller,
                      builder: (context, transform, trench) => Offstage(
                        offstage: _covered(transform, viewport),
                        child: trench,
                      ),
                      child: TrenchBackdrop(
                          transform: controller, content: content),
                    ),
                  ),
                  // Rebuilt as the zoom changes, so it may zoom out further.
                  ValueListenableBuilder<Matrix4>(
                    valueListenable: controller,
                    builder: (context, transform, map) => InteractiveViewer(
                      constrained: false,
                      transformationController: controller,
                      minScale: MapViewFit.overviewScale(viewport, content),
                      maxScale: maxScale,
                      boundaryMargin: MapViewFit.abyssAround(viewport,
                          content, transform.getMaxScaleOnAxis()),
                      child: map!,
                    ),
                    child: map,
                  ),
                  const Positioned.fill(child: DepthHaze()),
                  Positioned.fill(
                    child: MapSnowLayer(
                        clock: clock, transform: controller, content: content),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
