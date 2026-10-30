import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../map/decor/map_decor_drawer.dart';
import '../map/map_sprites.dart';
import 'base_cable.dart';
import 'base_decor.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_pad_drawer.dart';
import 'base_pad_tier.dart';
import 'base_plateau.dart';
import 'base_rampart.dart';
import 'base_rampart_drawer.dart';
import 'base_walkway_drawer.dart';
import 'base_walkways.dart';

/// Paints the still island of the base over its whole view: the plateau
/// (see [paintBasePlateau]: the trench behind, the spire under it with
/// the Descent module's cable hanging along it, the slab, the floor),
/// the walkways from the headquarters to every building built,
/// the pad of every slot at its tier, the back edges of the [rampart]
/// and the decor standing between the slots (see [baseDecorOf]).
///
/// Nothing in it moves: rasterized into a bitmap by the base's layers, it
/// is painted once and only again when a pad changes [tiers], the
/// rampart grows, the [fit] or the [sprites] change; never when a
/// building rises within its tier, nor as the base comes alive above it.
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
    paintBasePlateau(
      canvas,
      size,
      fit,
      cells: layout.size,
      slabSalt: slabSalt,
      sprites: sprites,
      onSpire: (bottom) =>
          BaseCable.of(layout, _built)?.paint(canvas, bottom: bottom),
    );
    final walkway = BaseWalkwayDrawer();
    for (final leg in baseWalkways(layout, _built)) {
      walkway.paint(canvas, leg);
    }
    _paintPads(canvas);
    paintBaseRampart(canvas, rampart.back);
    final images = sprites;
    if (images != null) {
      MapDecorDrawer(
        imageOf: images.svg,
        shadow: images.shadow,
        atlas: images.floor,
        shadowSprite: MapSprites.shadowSprite,
      ).draw(canvas, baseDecorOf(layout));
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
