import 'package:flutter/widgets.dart';

import '../ambience/ambience_clock.dart';
import '../guide/guide_cell_halo.dart';
import 'effects/map_effects.dart';
import 'effects/map_effects_layer.dart';
import 'map_cell_visual.dart';
import 'map_painter.dart';
import 'map_projection.dart';
import 'map_sprites.dart';
import 'map_standing_painter.dart';
import 'scout_token_layer.dart';

/// The stacked layers of a map: the still floor, what the [effects] lay
/// on it, the contents standing on it (back to front, over the fog, those
/// an effect fades faded), the scouts sent exploring, the rest of the
/// [effects] played over the map (which may shake it all), then the
/// guide's halo.
///
/// The map's box holds the projected map; the layers, shifted to the
/// projection's origin, draw in projection coordinates. Each painted
/// layer has its own repaint boundary, so the ambience [clock] and
/// panning ([transform]) never repaint the still floor.
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

  /// Effects played over the map, if any.
  final MapEffects? effects;

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
    this.effects,
  });

  @override
  Widget build(BuildContext context) {
    final rows = columns == 0 ? 0 : visuals.length ~/ columns;
    final size = MapProjection.sizeOf(columns, rows);
    final effects = this.effects;
    final standing = [
      RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: MapStandingPainter(
            visuals: visuals,
            columns: columns,
            sprites: sprites,
            clock: clock,
            transform: transform,
            viewport: viewport,
            fade: effects?.fade,
          ),
        ),
      ),
      ScoutTokenLayer(
        targets: pendingTargets,
        originOf: scoutOriginOf,
        size: size,
      ),
    ];
    final stack = Stack(clipBehavior: Clip.none, children: [
      RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: MapPainter(
              visuals: visuals, columns: columns, sprites: sprites),
        ),
      ),
      if (effects == null)
        ...standing
      else
        MapEffectsLayer(
          effects: effects,
          size: size,
          originOf: scoutOriginOf,
          sprites: sprites,
          columns: columns,
          rows: rows,
          child: Stack(clipBehavior: Clip.none, children: standing),
        ),
      GuideCellHalo(level: level, boxOf: MapProjection.tileRectOf),
    ]);
    final layers = Transform.translate(
        offset: MapProjection.originOf(rows), child: stack);
    if (effects == null) return layers;
    return ValueListenableBuilder<Offset>(
      valueListenable: effects.shake,
      builder: (context, shake, child) =>
          Transform.translate(offset: shake, child: child),
      child: layers,
    );
  }
}
