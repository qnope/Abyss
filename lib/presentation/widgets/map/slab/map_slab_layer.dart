import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../map_projection.dart';
import '../map_view_fit.dart';
import 'iso_slab.dart';
import 'map_slab_painter.dart';
import 'slab_rock_chunks.dart';

/// The rock slab a map [columns] by [rows] cells stands on (see
/// [MapSlabPainter]), in projection coordinates, in a boundary of its own.
///
/// Its strata, stones and algae are costly paths, where pictures are not
/// raster-cached (the web, Impeller): they are drawn from bitmaps of the
/// stretches the map seen through [transform] (in a [viewport]) shows,
/// as sharp as its zoom asks (see [SlabRockChunks]), kept while the
/// layer lives; whole faces as coarse as the overview's.
class MapSlabLayer extends StatefulWidget {
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
  State<MapSlabLayer> createState() => _MapSlabLayerState();
}

class _MapSlabLayerState extends State<MapSlabLayer> {
  /// Counts the bitmaps made ready, to paint them.
  final _ready = ValueNotifier(0);
  late IsoSlab _slab;
  late SlabRockChunks _chunks;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _slab = IsoSlab(
        columns: widget.columns, rows: widget.rows, salt: widget.salt);
    _chunks = SlabRockChunks(_slab, onReady: () => _ready.value++);
  }

  @override
  void didUpdateWidget(MapSlabLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.columns, oldWidget.rows, oldWidget.salt) ==
        (widget.columns, widget.rows, widget.salt)) {
      return;
    }
    _chunks.dispose();
    _build();
  }

  @override
  void dispose() {
    _chunks.dispose();
    _ready.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (columns, rows) = (widget.columns, widget.rows);
    final content = MapProjection.sizeOf(columns, rows);
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final overview = MapViewFit.overviewScale(widget.viewport, content);
    return RepaintBoundary(
      child: CustomPaint(
        size: content,
        painter: MapSlabPainter(
          slab: _slab,
          chunks: _chunks,
          transform: widget.transform,
          viewport: widget.viewport,
          origin: MapProjection.originOf(rows),
          clear: MapSlabLayer.clearOf(columns, rows),
          ratio: ratio,
          coarsest: SlabRockChunks.resolutionFor(overview * ratio),
          repaint: Listenable.merge([widget.transform, _ready]),
        ),
      ),
    );
  }
}
