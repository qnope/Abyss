import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../common/raster_paint.dart';
import 'parallax_drift.dart';

/// A far layer of scenery behind a pannable content (a map, a base),
/// sliding at a share ([rate]) of the content's drift (see
/// [contentDrift]): 0 stays still, 1 follows the content.
///
/// Its [tile] is painted once for the viewport's size and [overscan] (a
/// share of the viewport's height) beyond its top and bottom, into a
/// bitmap at [resolution] (the device's by default, see [RasterPaint])
/// drawn twice side by side, in its own repaint boundary; panning then
/// only moves that layer ([parallaxShift]), never repainting it. The
/// [tile] must join seamlessly across its left and right edges and cover
/// the overscan. Never takes a tap.
class ParallaxLayer extends StatelessWidget {
  /// The pan and zoom of the content the layer follows.
  final ValueListenable<Matrix4> transform;

  /// Size of the content, to find its centre.
  final Size content;

  final double rate;
  final CustomPainter tile;
  final double overscan;
  final double? resolution;

  const ParallaxLayer({
    super.key,
    required this.transform,
    required this.content,
    required this.rate,
    required this.tile,
    this.overscan = 0.2,
    this.resolution,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: LayoutBuilder(builder: (context, constraints) {
          final viewport = constraints.biggest;
          final margin = overscan * viewport.height;
          return Stack(clipBehavior: Clip.hardEdge, children: [
            Positioned(
              left: 0,
              top: -margin,
              width: 2 * viewport.width,
              height: viewport.height + 2 * margin,
              child: AnimatedBuilder(
                animation: transform,
                builder: (context, child) => Transform.translate(
                  offset: parallaxShift(
                      contentDrift(transform.value, content, viewport),
                      rate: rate,
                      period: viewport.width,
                      overscan: margin),
                  child: child,
                ),
                child: RepaintBoundary(
                  child: RasterPaint(
                    painter: _OverscanPainter(tile, margin: margin),
                    repeat: 2,
                    resolution: resolution,
                  ),
                ),
              ),
            ),
          ]);
        }),
      );
}

/// Paints [tile] at its size, shifted down by the [margin] left above it.
class _OverscanPainter extends CustomPainter {
  final CustomPainter tile;
  final double margin;

  const _OverscanPainter(this.tile, {required this.margin});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, margin);
    tile.paint(canvas, Size(size.width, size.height - 2 * margin));
  }

  @override
  bool shouldRepaint(_OverscanPainter oldDelegate) =>
      oldDelegate.margin != margin ||
      oldDelegate.tile.runtimeType != tile.runtimeType ||
      tile.shouldRepaint(oldDelegate.tile);
}
