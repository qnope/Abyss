import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../common/svg_raster_cache.dart';
import '../map_cell_visual.dart';
import '../map_sprites.dart';

/// Something the map plays once over its cells: an attack on a lair,
/// and later the story of a turn.
///
/// A new kind of effect is a subclass whose [stage] places it on a map
/// and returns its [MapEffectRun], which paints it moment by moment.
/// `MapEffects` plays it; `MapEffectsLayer` shows it.
abstract class MapEffect {
  const MapEffect();

  /// Bitmaps the effect draws, rasterized before it starts.
  Set<String> get imagePaths => const {};

  /// The cell the map centres on as the effect plays, if any.
  (int, int)? get focus => null;

  /// The effect placed on the map shown by [stage].
  MapEffectRun stage(MapStage stage);
}

/// An effect placed on a map, painted as its time runs.
///
/// Most of it is painted over the map; what lies on the floor may be
/// painted under the contents standing on it ([paintFloor]), and the
/// contents of some cells may fade meanwhile ([fadedCells]).
abstract class MapEffectRun {
  /// How long the effect plays.
  Duration get duration;

  /// How far the whole map is shaken [elapsed] into the effect.
  Offset shakeAt(Duration elapsed);

  /// Paints the effect [elapsed] into it over the map, in projection
  /// coordinates.
  void paint(Canvas canvas, Duration elapsed);

  /// Paints what the effect lays on the floor [elapsed] into it, under
  /// the contents standing on the map: nothing by default.
  void paintFloor(Canvas canvas, Duration elapsed) {}

  /// Cells whose standing content shows at [contentOpacityAt] as the
  /// effect plays: none by default.
  Set<(int, int)> get fadedCells => const {};

  /// How much the contents of [fadedCells] show [elapsed] into the
  /// effect: 0 hidden, 1 whole.
  double contentOpacityAt(Duration elapsed) => 1;
}

/// What an effect needs to know of the map playing it.
class MapStage {
  /// The map's sprites, or `null` while they load.
  final MapSprites? sprites;

  /// The cell the player's units sent to a target set off from.
  final (int, int) Function((int, int) target) originOf;

  /// Size of the map in cells, or `null` when unknown.
  final int? columns, rows;

  const MapStage({
    required this.originOf,
    this.sprites,
    this.columns,
    this.rows,
  });

  /// The bitmap of the SVG at [path], or `null` while it loads.
  ui.Image? image(String path) =>
      sprites?.svg(path) ?? SvgRasterCache.peek(path);

  /// The pool of light [glow] casts on the floor, or `null` while it
  /// loads.
  ui.Image? pool(MapGlow glow) => sprites?.pool(glow);

  /// The contact shadow under a standing content, or `null` while it
  /// loads.
  ui.Image? get shadow => sprites?.shadow;
}
