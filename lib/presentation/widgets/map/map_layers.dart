import 'package:flutter/widgets.dart';

import '../ambience/ambience_clock.dart';
import '../guide/guide_cell_halo.dart';
import 'map_ambience_painter.dart';
import 'map_cell_visual.dart';
import 'map_painter.dart';
import 'map_sprites.dart';
import 'scout_token_layer.dart';

/// The stacked layers of a map, in map coordinates: the still map, the
/// moving contents above it, the scouts sent exploring, then the guide's
/// halo.
///
/// Each painted layer has its own repaint boundary, so the ambience
/// [clock] and panning ([transform]) never repaint the still map.
class MapLayers extends StatelessWidget {
  final List<MapCellVisual> visuals;
  final int columns;
  final MapSprites? sprites;
  final AmbienceClock clock;
  final ValueNotifier<Matrix4> transform;

  /// Size of the screen area the map is seen through.
  final Size viewport;

  /// Level of the map, where the guide's halo may surround a cell.
  final int level;

  /// Cells of the map the scouts were sent to, still to be explored.
  final Set<(int, int)> pendingTargets;

  /// The cell a scout sent to a target sets off from.
  final (int, int) Function((int, int) target) scoutOriginOf;

  const MapLayers({
    super.key,
    required this.visuals,
    required this.columns,
    required this.clock,
    required this.transform,
    required this.viewport,
    required this.level,
    required this.scoutOriginOf,
    this.pendingTargets = const {},
    this.sprites,
  });

  @override
  Widget build(BuildContext context) {
    final rows = columns == 0 ? 0 : visuals.length ~/ columns;
    final size = Size(columns * cellSize, rows * cellSize);
    return Stack(children: [
      RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: MapPainter(
              visuals: visuals, columns: columns, sprites: sprites),
        ),
      ),
      RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: MapAmbiencePainter(
            visuals: visuals,
            columns: columns,
            sprites: sprites,
            clock: clock,
            transform: transform,
            viewport: viewport,
          ),
        ),
      ),
      ScoutTokenLayer(
        targets: pendingTargets,
        originOf: scoutOriginOf,
        size: size,
      ),
      GuideCellHalo(level: level, cellSize: cellSize),
    ]);
  }
}
