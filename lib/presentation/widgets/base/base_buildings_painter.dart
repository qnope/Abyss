import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../theme/abyss_island_colors.dart';
import '../map/map_content_drawer.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_slot_projection.dart';
import 'base_sprites.dart';

/// Paints the eleven buildings of the base standing on the island, back
/// to front in [BaseLayout.drawOrder]: first the soft contact shadow of
/// every built one on the floor, then each building's cut-out sprite, a
/// translucent cyan ghost while it is still to build (level 0).
///
/// Each building is a single draw of an already rasterized bitmap, the
/// ghost tinted by its paint: no layer, no vector replayed.
class BaseBuildingsPainter extends CustomPainter {
  final BaseLayout layout;

  /// The level of each building; 0 for one still to build.
  final Map<BuildingType, int> levels;
  final BaseFit fit;

  /// The bitmaps, nothing drawn while they load.
  final BaseSprites? sprites;

  final MapContentDrawer _drawer;
  final _sprite = Paint()..filterQuality = FilterQuality.medium;
  final _ghost = Paint()
    ..filterQuality = FilterQuality.medium
    ..colorFilter = AbyssIslandColors.ghost;
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  BaseBuildingsPainter({
    required this.layout,
    required this.levels,
    required this.fit,
    this.sprites,
  }) : _drawer = MapContentDrawer(sprites?.map);

  bool _isBuilt(BuildingType type) => (levels[type] ?? 0) > 0;

  @override
  void paint(Canvas canvas, Size size) {
    final sprites = this.sprites;
    if (sprites == null) return;
    canvas.save();
    fit.apply(canvas);
    final order = layout.drawOrder;
    for (final type in order) {
      if (!_isBuilt(type)) continue;
      final box = layout.slotOf(type).shadowBox;
      _drawer.drawOnFloor(canvas, sprites.map.shadow, box, _shadow);
    }
    for (final type in order) {
      final box = layout.slotOf(type).standingBox;
      final paint = _isBuilt(type) ? _sprite : _ghost;
      _drawer.drawSprite(canvas, sprites.standingOf(type), box, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BaseBuildingsPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      !mapEquals(oldDelegate.levels, levels);

  @override
  bool? hitTest(Offset position) => false;
}
