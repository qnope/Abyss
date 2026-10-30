import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../common/painted_raster.dart';
import 'map_cell_visual.dart';
import 'map_painter.dart';
import 'map_projection.dart';
import 'map_sprites.dart';
import 'slab/map_slab_layer.dart';

/// The still floor of a map (see [MapPainter]), in its own repaint
/// boundary, sized to the map's box and drawn in projection coordinates.
///
/// Keeps the bitmap of its fog from one build to the next, rasterized
/// again only once other cells are hidden, in the background (the fog
/// drawn live meanwhile, never holding a frame), and disposes it when it
/// goes.
/// The slab the map stands on lies just above (see [MapSlabLayer]),
/// following the map seen through [transform] in a [viewport].
class MapFloor extends StatefulWidget {
  final List<MapCellVisual> visuals;
  final int columns;
  final MapSprites? sprites;

  /// Level of the map, which scatters the decor between the cells.
  final int level;

  /// The pan and zoom of the map's box, as its InteractiveViewer's.
  final ValueListenable<Matrix4> transform;
  final Size viewport;

  const MapFloor({
    super.key,
    required this.visuals,
    required this.columns,
    required this.level,
    required this.transform,
    required this.viewport,
    this.sprites,
  });

  @override
  State<MapFloor> createState() => _MapFloorState();
}

class _MapFloorState extends State<MapFloor> {
  /// Counts the bitmaps of the fog made ready, to paint them.
  final _fogReady = ValueNotifier(0);
  late final _fog = PaintedRaster(onReady: () => _fogReady.value++);

  @override
  void dispose() {
    _fog.dispose();
    _fogReady.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.columns;
    final rows = columns == 0 ? 0 : widget.visuals.length ~/ columns;
    final size = MapProjection.sizeOf(columns, rows);
    return Stack(
        alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
      RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: MapPainter(
            visuals: widget.visuals,
            columns: columns,
            sprites: widget.sprites,
            decorSalt: widget.level,
            fogRaster: _fog,
            slab: false,
            repaint: _fogReady,
          ),
        ),
      ),
      MapSlabLayer(
        columns: columns,
        rows: rows,
        salt: widget.level,
        transform: widget.transform,
        viewport: widget.viewport,
      ),
    ]);
  }
}
