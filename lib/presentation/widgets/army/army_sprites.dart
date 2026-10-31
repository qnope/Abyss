import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../common/svg_raster_cache.dart';
import '../map/map_sprites.dart';

/// Bitmaps the squads of the parade ground draw, rasterized once and
/// shared, as the base's (see BaseSprites): the map's contact shadow,
/// every unit standing, at its own aspect (see
/// [SvgRasterCache.pixelSizeOf]), and every unit's portrait for its
/// banner.
class ArmySprites {
  static Future<ArmySprites>? _shared;
  static ArmySprites? _ready;

  /// The map's sprites, for the contact shadow under each figure.
  final MapSprites map;

  final Map<UnitType, ui.Image> _standing;
  final Map<UnitType, ui.Image> _portraits;

  const ArmySprites._(this.map, this._standing, this._portraits);

  /// A unit of [type] standing, its feet near the bottom.
  ui.Image? standingOf(UnitType type) => _standing[type];

  /// The portrait of [type], on its banner.
  ui.Image? portraitOf(UnitType type) => _portraits[type];

  /// The shared sprites if already loaded, so the army can paint them on
  /// its very first frame.
  static ArmySprites? get ready => _ready ??= _peek();

  /// Forgets the shared sprites and their load under way, as at startup.
  @visibleForTesting
  static void debugReset() {
    _shared = null;
    _ready = null;
  }

  /// Loads the shared sprites, rasterizing them on first use only.
  static Future<ArmySprites> load() {
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

  /// The sprites when every bitmap is rasterized already.
  static ArmySprites? _peek() {
    final map = MapSprites.ready;
    if (map == null) return null;
    final standing = _peekAll((type) => type.standingPath);
    final portraits = _peekAll((type) => type.iconPath);
    if (standing == null || portraits == null) return null;
    return ArmySprites._(map, standing, portraits);
  }

  static Map<UnitType, ui.Image>? _peekAll(String Function(UnitType) path) {
    final images = <UnitType, ui.Image>{};
    for (final type in UnitType.values) {
      final image = SvgRasterCache.peek(path(type));
      if (image == null) return null;
      images[type] = image;
    }
    return images;
  }

  static Future<ArmySprites> _rasterizeAll() async {
    const types = UnitType.values;
    Future<Map<UnitType, ui.Image>> all(String Function(UnitType) path) async =>
        Map.fromIterables(
          types,
          await Future.wait(
            types.map((type) => SvgRasterCache.load(path(type))),
          ),
        );
    return ArmySprites._(
      await MapSprites.load(),
      await all((type) => type.standingPath),
      await all((type) => type.iconPath),
    );
  }
}
