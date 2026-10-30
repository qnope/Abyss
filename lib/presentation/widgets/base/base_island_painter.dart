import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/map/terrain_type.dart';
import '../../theme/abyss_colors.dart';
import '../map/map_content_drawer.dart';
import '../map/map_floor_tiles.dart';
import '../map/map_projection.dart';
import '../map/map_scatter.dart';
import '../map/map_sprites.dart';
import 'base_backdrop.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_slab.dart';
import 'base_spire.dart';
import 'base_walkway_drawer.dart';
import 'base_walkways.dart';

/// Paints the still island of the base over its whole view: the water
/// behind, the spire and the slab under the plateau, the plateau's floor
/// in the map's diamond tiles, and the walkways from the headquarters to
/// every [built] building.
///
/// Nothing in it moves: within its repaint boundary, it is painted once
/// and only repainted when the [built] buildings, the [fit] or the
/// [sprites] change, never as the base comes alive above it.
class BaseIslandPainter extends CustomPainter {
  final BaseLayout layout;
  final Set<BuildingType> built;
  final BaseFit fit;

  /// The floor tiles, plain diamonds while they load.
  final MapSprites? sprites;

  const BaseIslandPainter({
    required this.layout,
    required this.built,
    required this.fit,
    this.sprites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintBaseBackdrop(canvas, size);
    canvas.save();
    fit.apply(canvas);
    final below = fit.toProjection(Offset(0, size.height)).dy;
    const depth = BaseFit.slabDepth;
    paintBaseSpire(canvas, layout.size, depth, bottom: below);
    paintBaseSlab(canvas, layout.size, depth);
    _paintFloor(canvas);
    final walkway = BaseWalkwayDrawer();
    for (final leg in baseWalkways(layout, built)) {
      walkway.paint(canvas, leg);
    }
    canvas.restore();
  }

  void _paintFloor(Canvas canvas) {
    final tile = Paint()..filterQuality = FilterQuality.medium;
    final fallback = Paint()..color = AbyssColors.trench;
    final drawer = MapContentDrawer(sprites);
    for (var y = 0; y < layout.size; y++) {
      for (var x = 0; x < layout.size; x++) {
        final cell = (x, y);
        final image = sprites?.svg(floorTileOf(TerrainType.plain, cell));
        image == null
            ? canvas.drawPath(MapProjection.diamondOf(cell), fallback)
            : drawer.drawSprite(canvas, image, MapFloorTiles.tileOf(cell), tile);
      }
    }
  }

  @override
  bool shouldRepaint(BaseIslandPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      !setEquals(oldDelegate.built, built);

  @override
  bool? hitTest(Offset position) => false;
}
