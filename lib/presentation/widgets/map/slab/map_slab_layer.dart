import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../common/raster_paint.dart';
import '../map_projection.dart';
import '../map_view_fit.dart';
import '../viewport_cover.dart';
import 'iso_slab_painter.dart';

/// The rock slab a map [columns] by [rows] cells stands on (see
/// [IsoSlabPainter]), in projection coordinates, in a boundary of its own.
///
/// Its strata and stones are costly paths, even off screen where
/// pictures are not raster-cached (the web, Impeller): it is left
/// unpainted while the map seen through [transform] (in a [viewport])
/// shows none of it, drawn from one bitmap (sharp up to [bitmapZoom]
/// times the overview's scale) while zoomed out, and painted live only
/// zoomed in further, the bitmap kept for the way back.
class MapSlabLayer extends StatelessWidget {
  /// How far past the screen's edges the slab must lie to be left out:
  /// more than a blow shakes the map, and its lit lips.
  static const margin = 8.0;

  /// The zoom, over the overview's, up to which the bitmap stays sharp.
  static const bitmapZoom = 2.0;

  final int columns;
  final int rows;
  final int salt;

  /// The pan and zoom of the map's box, as its InteractiveViewer's.
  final ValueListenable<Matrix4> transform;
  final Size viewport;

  const MapSlabLayer({
    super.key,
    required this.columns,
    required this.rows,
    required this.salt,
    required this.transform,
    required this.viewport,
  });

  /// The part of the map's box no slab of a map [columns] by [rows]
  /// reaches: over both front edges, as far as the eye goes.
  static List<Offset> clearOf(int columns, int rows) {
    final [_, right, bottom, left] = MapProjection.outlineOf(columns, rows);
    final origin = MapProjection.originOf(rows);
    const far = 1000.0;
    return [
      for (final point in [
        bottom + (left - bottom) * far, bottom, bottom + (right - bottom) * far,
      ])
        point + origin,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slab = IsoSlabPainter(columns: columns, rows: rows, salt: salt);
    final content = MapProjection.sizeOf(columns, rows);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final resolution =
        bitmapZoom * MapViewFit.overviewScale(viewport, content) * ratio;
    final bounds = IsoSlabPainter.boundsOf(columns, rows);
    final clear = clearOf(columns, rows);
    final live = RepaintBoundary(
        child: CustomPaint(size: content, painter: slab));
    final bitmap = RepaintBoundary(
      child: RasterPaint(
        painter: _Shifted(slab, -bounds.topLeft),
        resolution: resolution,
        filterQuality: FilterQuality.medium,
      ),
    );
    return ValueListenableBuilder<Matrix4>(
      valueListenable: transform,
      builder: (context, transform, _) {
        final hidden =
            coversViewport(clear, transform, viewport, margin: margin);
        final fine = transform.storage[0] * ratio > resolution;
        return Stack(
            alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
          Offstage(offstage: hidden || !fine, child: live),
          Positioned.fromRect(
            rect: bounds,
            child: Offstage(offstage: hidden || fine, child: bitmap),
          ),
        ]);
      },
    );
  }
}

/// Paints [painter] moved by [shift].
class _Shifted extends CustomPainter {
  final CustomPainter painter;
  final Offset shift;

  const _Shifted(this.painter, this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(shift.dx, shift.dy);
    painter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(_Shifted oldDelegate) =>
      oldDelegate.shift != shift ||
      oldDelegate.painter.runtimeType != painter.runtimeType ||
      painter.shouldRepaint(oldDelegate.painter);
}
