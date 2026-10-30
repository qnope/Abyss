import 'package:flutter/rendering.dart';

import '../../../domain/unit/unit_type.dart';
import '../base/base_fit.dart';
import 'army_banner_drawer.dart';
import 'army_draw_order.dart';
import 'army_piece.dart';
import 'army_roster.dart';
import 'army_sprites.dart';
import 'army_squad_drawer.dart';

/// Paints the living part of the parade ground over its still island
/// (see ArmyIslandPainter): the banner and the figures of every squad, in
/// the depth order of [ArmyDrawOrder].
///
/// The barracks and the depot stay in the island's bitmap: every banner
/// and figure stands in front of the barracks and behind the depot, and
/// none of them reaches over the depot on the screen, so drawing them
/// all above the bitmap keeps the order right.
///
/// Repainted only when a squad gains or loses a figure or a unit is
/// unlocked, never the island under it.
class ArmySquadsPainter extends CustomPainter {
  final BaseFit fit;
  final ArmyRoster roster;
  final ArmySprites sprites;

  ArmySquadsPainter({
    required this.fit,
    required this.roster,
    required this.sprites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final squads = ArmySquadDrawer(sprites);
    final banners = ArmyBannerDrawer();
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    fit.apply(canvas);
    for (final piece in ArmyDrawOrder.backToFront) {
      switch (piece) {
        case BannerPiece(:final type):
          banners.paint(
            canvas,
            type,
            sprites.portraitOf(type),
            locked: roster.isLocked(type),
          );
        case SquadPiece(:final type):
          squads.paint(
            canvas,
            type,
            figures: roster.figuresOf(type),
            locked: roster.isLocked(type),
          );
        case BarracksPiece() || DepotPiece():
          continue;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ArmySquadsPainter oldDelegate) =>
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      UnitType.values.any(
        (type) =>
            oldDelegate.roster.isLocked(type) != roster.isLocked(type) ||
            oldDelegate.roster.figuresOf(type) != roster.figuresOf(type),
      );

  @override
  bool? hitTest(Offset position) => false;
}
