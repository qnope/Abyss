import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/map/terrain_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../backdrop/trench/trench_backdrop.dart';
import '../map/decor/map_decor_drawer.dart';
import '../map/map_content_drawer.dart';
import '../map/map_floor_tiles.dart';
import '../map/map_projection.dart';
import '../map/map_scatter.dart';
import '../map/map_sprites.dart';
import '../map/slab/iso_slab_painter.dart';
import 'base_cable.dart';
import 'base_decor.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_pad_drawer.dart';
import 'base_pad_tier.dart';
import 'base_rampart.dart';
import 'base_rampart_drawer.dart';
import 'base_spire.dart';
import 'base_walkway_drawer.dart';
import 'base_walkways.dart';

/// Paints the still island of the base over its whole view: the trench
/// behind, the spire under the plateau and the Descent module's cable
/// hanging along it, the slab, the plateau's floor in the map's diamond
/// tiles, the walkways from the headquarters to every building built,
/// the pad of every slot at its tier, the back edges of the [rampart]
/// and the decor standing between the slots (see [baseDecorOf]).
///
/// Nothing in it moves: within its repaint boundary, it is painted once
/// and only repainted when a pad changes [tiers], the rampart grows, the
/// [fit] or the [sprites] change; never when a building rises within its
/// tier, nor as the base comes alive above it.
class BaseIslandPainter extends CustomPainter {
  /// The salt of the slab's rock, as on the mockup.
  static const slabSalt = 5;

  final BaseLayout layout;

  /// The pad under each building, a plot for a slot with none.
  final Map<BuildingType, BasePadTier> tiers;
  final BaseFit fit;

  /// The floor tiles and decor, plain diamonds and none while they load.
  final MapSprites? sprites;
  final BaseRampart rampart;

  const BaseIslandPainter({
    required this.layout,
    required this.tiers,
    required this.fit,
    this.sprites,
    this.rampart = const BaseRampart.none(),
  });

  Set<BuildingType> get _built => {
        for (final MapEntry(:key, :value) in tiers.entries)
          if (value != BasePadTier.plot) key,
      };

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    const TrenchWaterPainter().paint(canvas, size);
    const TrenchRidgesPainter().paint(canvas, size);
    fit.apply(canvas);
    final below = fit.toProjection(Offset(0, size.height)).dy;
    const depth = BaseFit.slabDepth;
    final n = layout.size;
    paintBaseSpire(canvas, n, depth, bottom: below);
    BaseCable.of(layout, _built)?.paint(canvas, bottom: below);
    IsoSlabPainter(columns: n, rows: n, depth: depth, salt: slabSalt)
        .paint(canvas, size);
    _paintFloor(canvas);
    final walkway = BaseWalkwayDrawer();
    for (final leg in baseWalkways(layout, _built)) {
      walkway.paint(canvas, leg);
    }
    _paintPads(canvas);
    paintBaseRampart(canvas, rampart.back);
    final images = sprites;
    if (images != null) {
      MapDecorDrawer(imageOf: images.svg, shadow: images.shadow)
          .draw(canvas, baseDecorOf(layout));
    }
    canvas.restore();
  }

  void _paintPads(Canvas canvas) {
    final pad = BasePadDrawer();
    for (final type in layout.drawOrder) {
      final tier = tiers[type] ?? BasePadTier.plot;
      pad.paint(canvas, layout.slotOf(type), tier, type.color,
          seed: type.index);
    }
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
      oldDelegate.rampart != rampart ||
      !mapEquals(oldDelegate.tiers, tiers);

  @override
  bool? hitTest(Offset position) => false;
}
