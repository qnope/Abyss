import 'dart:ui' as ui;

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/monster_difficulty.dart';
import '../../../domain/map/terrain_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';
import '../common/svg_raster_cache.dart';
import 'map_cell_visual.dart';
import 'map_glow_sprites.dart';

/// Bitmaps of every map sprite, rasterized once and shared by all maps.
///
/// Drawing a bitmap is far cheaper than replaying an SVG's vector commands,
/// which matters when hundreds of cells are repainted while panning.
class MapSprites {
  /// Pixel size of each sprite: keeps the detailed art sharp when zoomed in.
  static const spriteSize = 256;

  static Future<MapSprites>? _shared;

  final Map<String, ui.Image> _svgs;
  final Map<MapGlow, ui.Image> _glows;

  const MapSprites._(this._svgs, this._glows);

  /// Loads the shared sprites, rasterizing them on first use only.
  static Future<MapSprites> load() {
    return _shared ??= _rasterizeAll().catchError((Object error) {
      _shared = null;
      throw error;
    });
  }

  ui.Image? svg(String path) => _svgs[path];

  ui.Image? glow(MapGlow glow) => _glows[glow];

  static Set<String> get svgPaths => {
        for (final terrain in TerrainType.values) terrain.svgPath,
        for (final content in CellContentType.values)
          if (content.svgPath != null) content.svgPath!,
        for (final difficulty in MonsterDifficulty.values) difficulty.svgPath,
        playerBaseSvgPath,
      };

  static Future<MapSprites> _rasterizeAll() async {
    final paths = svgPaths.toList();
    final glows = MapGlow.values.where((g) => g != MapGlow.none).toList();
    final svgImages = await Future.wait(
      paths.map((path) => SvgRasterCache.load(path, spriteSize)),
    );
    final glowImages = await Future.wait(
      glows.map((g) => rasterizeGlow(g, spriteSize)),
    );
    return MapSprites._(
      Map.fromIterables(paths, svgImages),
      Map.fromIterables(glows, glowImages),
    );
  }
}
