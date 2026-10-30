import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/unit/unit_type.dart';
import '../base/base_fit.dart';
import '../base/base_plateau.dart';
import '../base/base_sprites.dart';
import '../base/base_walkway_drawer.dart';
import '../map/decor/map_decor_drawer.dart';
import '../map/map_sprites.dart';
import 'army_barracks_drawer.dart';
import 'army_crest_drawer.dart';
import 'army_decor.dart';
import 'army_draw_order.dart';
import 'army_depot_drawer.dart';
import 'army_drill_pad_drawer.dart';
import 'army_layout.dart';
import 'army_piece.dart';
import 'army_slots.dart';

/// Paints the still parade ground of the army over its whole view, an
/// island like the base's: the plateau (see [paintBasePlateau]), the four
/// alleys between its blocks, the crest flat in the middle, the barracks'
/// pad and the six drill pads (laid for the [unlocked] units, surveyed
/// for the others), then, back to front, the decor, the barracks standing
/// and the depot; last the barracks' plaque.
///
/// Nothing in it moves: rasterized into a bitmap kept by the army's view,
/// it is painted once and only again when the barracks changes (its
/// level, degraded, its plot locked), a unit is unlocked, the [fit], the
/// texts or the [sprites] change; never as the army grows.
class ArmyIslandPainter extends CustomPainter {
  /// The salt of the slab's rock, as on the mockup.
  static const slabSalt = 6;

  final BaseFit fit;
  final int barracksLevel;
  final bool barracksDegraded;

  /// Whether a missing prerequisite keeps the barracks from being built.
  final bool barracksLocked;

  /// The units the barracks' level lets recruit.
  final Set<UnitType> unlocked;

  /// The pill of the barracks' plot, « À bâtir », and its name.
  final String toBuild;
  final String barracksName;

  /// The floor tiles, decor and barracks, plain diamonds and none of the
  /// others while they load.
  final BaseSprites? sprites;

  const ArmyIslandPainter({
    required this.fit,
    required this.barracksLevel,
    required this.unlocked,
    required this.toBuild,
    required this.barracksName,
    this.barracksDegraded = false,
    this.barracksLocked = false,
    this.sprites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    paintBasePlateau(canvas, size, fit,
        cells: ArmyLayout.islandSize.toInt(),
        slabSalt: slabSalt,
        sprites: sprites?.map);
    final alley = BaseWalkwayDrawer(width: ArmySlots.alleyWidth);
    for (final leg in ArmySlots.alleys) {
      alley.paint(canvas, leg);
    }
    const ArmyCrestDrawer().paint(canvas);
    final barracks = ArmyBarracksDrawer()..paintPad(canvas, barracksLevel);
    final pads = ArmyDrillPadDrawer();
    for (final type in UnitType.values) {
      pads.paint(canvas, type, unlocked: unlocked.contains(type));
    }
    _paintStanding(canvas, barracks);
    barracks.paintPlaque(canvas,
        level: barracksLevel,
        name: barracksName,
        toBuild: toBuild,
        locked: barracksLocked);
    canvas.restore();
  }

  /// The decor, the barracks and the depot, back to front (see
  /// [ArmyDrawOrder]): the decor in batches before, between and after the
  /// two buildings. The squads stand above, out of the still island.
  void _paintStanding(Canvas canvas, ArmyBarracksDrawer barracks) {
    final images = sprites;
    final decor = images == null
        ? null
        : MapDecorDrawer(
            imageOf: images.map.svg,
            shadow: images.map.shadow,
            atlas: images.map.floor,
            shadowSprite: MapSprites.shadowSprite,
          );
    var from = double.negativeInfinity;
    void decorUpTo(double depth) {
      decor?.draw(canvas, [
        for (final item in armyDecor)
          if (item.depth >= from && item.depth < depth) item.decor,
      ]);
      from = depth;
    }

    for (final piece in ArmyDrawOrder.backToFront) {
      switch (piece) {
        case BarracksPiece():
          decorUpTo(piece.depth);
          if (images == null) continue;
          barracks.paintStanding(canvas, images,
              level: barracksLevel, degraded: barracksDegraded);
        case DepotPiece():
          decorUpTo(piece.depth);
          ArmyDepotDrawer().paint(canvas);
        case UnitPiece():
          continue;
      }
    }
    decorUpTo(double.infinity);
  }

  @override
  bool shouldRepaint(ArmyIslandPainter oldDelegate) =>
      oldDelegate.fit != fit ||
      oldDelegate.barracksLevel != barracksLevel ||
      oldDelegate.barracksDegraded != barracksDegraded ||
      oldDelegate.barracksLocked != barracksLocked ||
      oldDelegate.toBuild != toBuild ||
      oldDelegate.barracksName != barracksName ||
      oldDelegate.sprites != sprites ||
      !setEquals(oldDelegate.unlocked, unlocked);

  @override
  bool? hitTest(Offset position) => false;
}
