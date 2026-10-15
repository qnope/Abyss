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
abstract interface class MapEffectRun {
  /// How long the effect plays.
  Duration get duration;

  /// How far the whole map is shaken [elapsed] into the effect.
  Offset shakeAt(Duration elapsed);

  /// Paints the effect [elapsed] into it, in map coordinates.
  void paint(Canvas canvas, Duration elapsed);
}

/// What an effect needs to know of the map playing it.
class MapStage {
  /// The map's sprites, or `null` while they load.
  final MapSprites? sprites;

  /// The cell the player's units sent to a target set off from.
  final (int, int) Function((int, int) target) originOf;

  const MapStage({required this.originOf, this.sprites});

  /// The bitmap of the SVG at [path], or `null` while it loads.
  ui.Image? image(String path) =>
      sprites?.svg(path) ?? SvgRasterCache.peek(path);

  /// The bitmap of [glow], or `null` while it loads.
  ui.Image? glow(MapGlow glow) => sprites?.glow(glow);
}
