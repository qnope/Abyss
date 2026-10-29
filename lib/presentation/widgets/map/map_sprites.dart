import 'dart:ui' as ui;

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/monster_difficulty.dart';
import '../../../domain/map/monster_family.dart';
import '../../../domain/map/terrain_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_family_extensions.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';
import '../common/svg_raster_cache.dart';
import 'map_cell_visual.dart';
import 'map_glow_sprites.dart';
import 'map_floor_sprites.dart';

/// Bitmaps of every map sprite, rasterized once and shared by all maps.
///
/// Drawing a bitmap is far cheaper than replaying an SVG's vector commands,
/// which matters when hundreds of cells are repainted while panning.
class MapSprites {
  /// Pixel size of each sprite: keeps the detailed art sharp when zoomed in.
  static const spriteSize = SvgRasterCache.pixels;

  static Future<MapSprites>? _shared;
  static MapSprites? _ready;

  final Map<String, ui.Image> _svgs;
  final Map<MapGlow, ui.Image> _glows;
  final Map<MapGlow, ui.Image> _pools;

  /// The soft contact shadow laid under every standing content.
  final ui.Image shadow;

  const MapSprites._(this._svgs, this._glows, this._pools, this.shadow);

  /// Loads the shared sprites, rasterizing them on first use only.
  static Future<MapSprites> load() {
    return _shared ??= _rasterizeAll().then(
      (sprites) => _ready = sprites,
      onError: (Object error) {
        _shared = null;
        throw error;
      },
    );
  }

  /// The shared sprites if already loaded (e.g. at startup), so a map can
  /// paint them on its very first frame.
  static MapSprites? get ready => _ready;

  ui.Image? svg(String path) => _svgs[path];

  ui.Image? glow(MapGlow glow) => _glows[glow];

  /// The pool of light [glow] casts on the floor around a content.
  ui.Image? pool(MapGlow glow) => _pools[glow];

  static Set<String> get svgPaths => {
        for (final terrain in TerrainType.values) ...[
          terrain.svgPath,
          ...terrain.tileSvgPaths,
        ],
        for (final content in CellContentType.values)
          if (content.svgPath != null) content.svgPath!,
        for (final difficulty in MonsterDifficulty.values) ...[
          difficulty.svgPath,
          for (final family in MonsterFamily.availableAt(3))
            family.svgPathAt(difficulty),
        ],
        ...postSvgPaths,
        playerBaseSvgPath,
        volcanoSealSvgPath,
      };

  static Future<MapSprites> _rasterizeAll() async {
    final paths = svgPaths.toList();
    final glows = MapGlow.values.where((g) => g != MapGlow.none).toList();
    final svgImages = await Future.wait(
      paths.map(SvgRasterCache.load),
    );
    final glowImages = await Future.wait(
      glows.map((g) => rasterizeGlow(g, spriteSize)),
    );
    final poolImages = await Future.wait(glows.map(rasterizePool));
    return MapSprites._(
      Map.fromIterables(paths, svgImages),
      Map.fromIterables(glows, glowImages),
      Map.fromIterables(glows, poolImages),
      await rasterizeShadow(),
    );
  }
}
