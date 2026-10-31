import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../common/svg_raster_cache.dart';
import '../map/map_sprites.dart';

/// Bitmaps the base draws, rasterized once and shared: the map's floor
/// tiles and contact shadow, and every building cut out of its card.
class BaseSprites {
  static Future<BaseSprites>? _shared;
  static BaseSprites? _ready;

  /// The map's sprites: the floor tiles and the contact shadow.
  final MapSprites map;

  final Map<BuildingType, ui.Image> _standing;

  const BaseSprites._(this.map, this._standing);

  /// The building of [type] standing on the ground.
  ui.Image? standingOf(BuildingType type) => _standing[type];

  /// The shared sprites if already loaded, so the base can paint them on
  /// its very first frame.
  static BaseSprites? get ready => _ready ??= _peek();

  /// Forgets the shared sprites and their load under way, as at startup.
  @visibleForTesting
  static void debugReset() {
    _shared = null;
    _ready = null;
  }

  /// Loads the shared sprites, rasterizing them on first use only.
  static Future<BaseSprites> load() {
    final ready = _ready;
    if (ready != null) return Future.value(ready);
    return _shared ??= _rasterizeAll().then(
      (sprites) => _ready = sprites,
      onError: (Object error) {
        _shared = null;
        throw error;
      },
    );
  }

  /// The sprites when every bitmap was rasterized at startup already.
  static BaseSprites? _peek() {
    final map = MapSprites.ready;
    if (map == null) return null;
    final standing = <BuildingType, ui.Image>{};
    for (final type in BuildingType.values) {
      final image = SvgRasterCache.peek(type.standingPath);
      if (image == null) return null;
      standing[type] = image;
    }
    return BaseSprites._(map, standing);
  }

  static Future<BaseSprites> _rasterizeAll() async {
    const types = BuildingType.values;
    final images = await Future.wait(
      types.map((type) => SvgRasterCache.load(type.standingPath)),
    );
    return BaseSprites._(
      await MapSprites.load(),
      Map.fromIterables(types, images),
    );
  }
}
