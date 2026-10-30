import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'parallax_drift.dart';

/// A far layer of scenery behind a pannable content (a map, a base),
/// sliding at a share ([rate]) of the content's drift (see
/// [contentDrift]): 0 stays still, 1 follows the content.
///
/// Its [tile] is painted once for the viewport's size, twice side by
/// side and [overscan] (a share of the viewport's height) beyond its top
/// and bottom, in its own repaint boundary; panning then only moves that
/// layer ([parallaxShift]), never repainting it. The [tile] must join
/// seamlessly across its left and right edges and cover the overscan.
/// Never takes a tap.
class ParallaxLayer extends StatelessWidget {
  /// The pan and zoom of the content the layer follows.
  final ValueListenable<Matrix4> transform;

  /// Size of the content, to find its centre.
  final Size content;

  final double rate;
  final CustomPainter tile;
  final double overscan;

  const ParallaxLayer({
    super.key,
    required this.transform,
    required this.content,
    required this.rate,
    required this.tile,
    this.overscan = 0.2,
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
                  child: CustomPaint(
                      painter: _TiledPainter(tile, margin: margin)),
                ),
              ),
            ),
          ]);
        }),
      );
}

/// Paints [tile] twice side by side, each clipped to its half and shifted
/// down by the [margin] left above it.
class _TiledPainter extends CustomPainter {
  final CustomPainter tile;
  final double margin;

  const _TiledPainter(this.tile, {required this.margin});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width / 2;
    final tileSize = Size(width, size.height - 2 * margin);
    for (var i = 0; i < 2; i++) {
      canvas
        ..save()
        ..clipRect(Rect.fromLTWH(i * width, 0, width, size.height))
        ..translate(i * width, margin);
      tile.paint(canvas, tileSize);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TiledPainter oldDelegate) =>
      oldDelegate.margin != margin ||
      oldDelegate.tile.runtimeType != tile.runtimeType ||
      tile.shouldRepaint(oldDelegate.tile);
}
