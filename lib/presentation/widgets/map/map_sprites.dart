import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/monster_difficulty.dart';
import '../../../domain/map/terrain_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';
import 'map_cell_visual.dart';
import 'map_glow_sprites.dart';

/// Bitmaps of every map sprite, rasterized once and shared by all maps.
///
/// Drawing a bitmap is far cheaper than replaying an SVG's vector commands,
/// which matters when hundreds of cells are repainted while panning.
class MapSprites {
  /// Pixel size of each sprite: sharp up to roughly 4x zoom on a 3x screen.
  static const spriteSize = 192;

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
    final svgImages = await Future.wait(paths.map(_rasterizeSvg));
    final glowImages = await Future.wait(
      glows.map((g) => rasterizeGlow(g, spriteSize)),
    );
    return MapSprites._(
      Map.fromIterables(paths, svgImages),
      Map.fromIterables(glows, glowImages),
    );
  }

  static Future<ui.Image> _rasterizeSvg(String path) async {
    final info = await vg.loadPicture(SvgAssetLoader(path), null);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(
      spriteSize / info.size.width,
      spriteSize / info.size.height,
    );
    canvas.drawPicture(info.picture);
    info.picture.dispose();
    final picture = recorder.endRecording();
    return picture
        .toImage(spriteSize, spriteSize)
        .whenComplete(picture.dispose);
  }
}
