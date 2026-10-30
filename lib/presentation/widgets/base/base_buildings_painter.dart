import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../map/map_content_drawer.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_sprite_paints.dart';
import 'base_sprites.dart';

/// Paints the eleven buildings of the base standing on the island, back
/// to front in [BaseLayout.drawOrder], each on top of its pad: first the
/// soft contact shadow of every built one, then each building's cut-out
/// sprite, a faint cyan ghost while it is still to build (level 0), or
/// greyed while [degraded].
///
/// Each building is a single draw of an already rasterized bitmap, the
/// ghost tinted by its paint: no layer, no vector replayed.
class BaseBuildingsPainter extends CustomPainter {
  final BaseLayout layout;

  /// The level of each building; 0 for one still to build.
  final Map<BuildingType, int> levels;

  /// The buildings a headquarters too low degrades: greyed, and still.
  final Set<BuildingType> degraded;
  final BaseFit fit;

  /// The bitmaps, nothing drawn while they load.
  final BaseSprites? sprites;

  final MapContentDrawer _drawer;
  final _paints = BaseSpritePaints();
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  BaseBuildingsPainter({
    required this.layout,
    required this.levels,
    this.degraded = const {},
    required this.fit,
    this.sprites,
  }) : _drawer = MapContentDrawer(sprites?.map);

  int _levelOf(BuildingType type) => levels[type] ?? 0;

  @override
  void paint(Canvas canvas, Size size) {
    final sprites = this.sprites;
    if (sprites == null) return;
    canvas.save();
    fit.apply(canvas);
    final order = layout.drawOrder;
    for (final type in order) {
      final tier = BasePadTier.ofLevel(_levelOf(type));
      if (tier == BasePadTier.plot) continue;
      final box = layout.slotOf(type).shadowBoxOn(tier);
      _drawer.drawOnFloor(canvas, sprites.map.shadow, box, _shadow);
    }
    for (final type in order) {
      final level = _levelOf(type);
      final box = layout.slotOf(type).standingBoxOn(BasePadTier.ofLevel(level));
      final paint =
          _paints.of(level: level, degraded: degraded.contains(type));
      _drawer.drawSprite(canvas, sprites.standingOf(type), box, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BaseBuildingsPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      !mapEquals(oldDelegate.levels, levels) ||
      !setEquals(oldDelegate.degraded, degraded);

  @override
  bool? hitTest(Offset position) => false;
}
