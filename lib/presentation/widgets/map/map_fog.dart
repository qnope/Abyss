import 'dart:ui';

import '../../theme/abyss_colors.dart';
import '../common/painted_raster.dart';

/// The fog over the hidden cells of a map, as [MapPainter] lays it: a
/// translucent black over their diamonds, its edge blurred.
///
/// The blur is costly to replay at every frame, where pictures are not
/// raster-cached (the web, Impeller): kept in a [PaintedRaster], the fog
/// is rasterized once while the same cells stay hidden, at [resolution]
/// as it is all soft, then drawn as one bitmap.
abstract final class MapFog {
  /// Blur of the fog's edge, in logical pixels.
  static const blur = 4.0;

  /// Pixels per logical pixel of the fog's bitmap: a pixel of blur still
  /// draws the same smooth edge, however far the map zooms in, and a
  /// bitmap this small costs a short hitch when a turn hides other cells
  /// on the web, where rasterizing holds the frame.
  static const resolution = 0.25;

  /// The box the fog over [path] spreads into, its blurred edge included.
  static Rect areaOf(Path path) => path.getBounds().inflate(3 * blur);

  /// Lays the fog over [path] on [canvas]: from the bitmap kept in
  /// [raster] while [hidden] (the cells under it) holds, or blurred live
  /// without a raster.
  static void paint(
    Canvas canvas,
    Path path,
    Object hidden, {
    PaintedRaster? raster,
  }) {
    void draw(Canvas canvas) => canvas.drawPath(
          path,
          Paint()
            ..color = AbyssColors.abyssBlack
                .withValues(alpha: AbyssColors.fogOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blur),
        );
    if (raster == null) return draw(canvas);
    final area = path.getBounds().isEmpty ? Rect.zero : areaOf(path);
    raster
      ..prepare(hidden, area, resolution, draw)
      ..drawOn(canvas);
  }
}
