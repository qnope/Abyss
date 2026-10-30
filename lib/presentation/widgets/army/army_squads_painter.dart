import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/unit/unit_type.dart';
import '../ambience/sprite_motion.dart';
import '../base/base_fit.dart';
import 'army_arrival_drawer.dart';
import 'army_banner_drawer.dart';
import 'army_draw_order.dart';
import 'army_helmet_bubbles.dart';
import 'army_piece.dart';
import 'army_roster.dart';
import 'army_sprites.dart';
import 'army_squad_drawer.dart';
import 'army_squad_geometry.dart';
import 'army_squad_pose.dart';
import 'squad_arrival.dart';

/// Paints the living part of the parade ground over its still island
/// (see ArmyIslandPainter): the banner and the figures of every squad, in
/// the depth order of [ArmyDrawOrder], the recruits [arriving] as the
/// [arrival] runs (see [ArmyArrivalDrawer]), and a few bubbles rising
/// from the helmets.
///
/// The barracks and the depot stay in the island's bitmap: every banner
/// and figure stands in front of the barracks and behind the depot, and
/// none of them reaches over the depot on the screen, so drawing them
/// all above the bitmap keeps the order right.
///
/// On the shared ambience [clock], the soldiers of the unlocked squads
/// breathe and their banners sway (see [ArmySquadPose]): only this layer
/// repaints as they live, never the island under it. Without a clock
/// (fewer animations asked), they stand still.
class ArmySquadsPainter extends CustomPainter {
  final BaseFit fit;
  final ArmyRoster roster;
  final ArmySprites sprites;

  /// Seconds of the shared ambience clock; nothing lives without it.
  final ValueListenable<double>? clock;

  /// The progress of the recruits [arriving], from 0 to 1.
  final Animation<double>? arrival;
  final Map<UnitType, SquadArrival> arriving;

  final ArmyHelmetBubbles? _bubbles;

  ArmySquadsPainter({
    required this.fit,
    required this.roster,
    required this.sprites,
    this.clock,
    this.arrival,
    this.arriving = const {},
  }) : _bubbles = clock == null ? null : ArmyHelmetBubbles(clock, roster),
       super(
         repaint: Listenable.merge([
           if (roster.unlocked.isNotEmpty) clock,
           arrival,
         ]),
       );

  @override
  void paint(Canvas canvas, Size size) {
    final squads = ArmySquadDrawer(sprites);
    final banners = ArmyBannerDrawer();
    final arrivals = ArmyArrivalDrawer(squads);
    final seconds = clock?.value, t = arrival?.value ?? 1;
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    fit.apply(canvas);
    for (final piece in ArmyDrawOrder.backToFront) {
      if (piece is! UnitPiece) continue;
      final type = piece.type, locked = roster.isLocked(type);
      final still = seconds == null || locked;
      switch (piece) {
        case BannerPiece():
          final foot = ArmySquadGeometry.bannerFoot(type, locked: locked);
          final pose =
              still ? SpriteMotion.rest : ArmySquadPose.banner(type, seconds);
          pose.paint(canvas, ArmySquadGeometry.bannerBox(foot), () {
            banners.paint(
              canvas,
              type,
              sprites.portraitOf(type),
              locked: locked,
            );
          });
        case SquadPiece():
          final coming = t < 1 ? arriving[type] : null;
          final falling = coming != null && SquadArrival.fallAt(t) > 0;
          squads.paint(
            canvas,
            type,
            figures: roster.figuresOf(type),
            locked: locked,
            poseOf:
                still
                    ? null
                    : (figure) => ArmySquadPose.soldier(type, figure, seconds),
            hidden: falling && coming.stays ? coming.figure : null,
          );
          if (coming != null) arrivals.paint(canvas, type, coming, t);
      }
    }
    canvas.restore();
    _bubbles?.paint(canvas, fit);
  }

  @override
  bool shouldRepaint(ArmySquadsPainter oldDelegate) =>
      oldDelegate.fit != fit ||
      oldDelegate.sprites != sprites ||
      oldDelegate.clock != clock ||
      oldDelegate.arrival != arrival ||
      !mapEquals(oldDelegate.arriving, arriving) ||
      UnitType.values.any(
        (type) =>
            oldDelegate.roster.isLocked(type) != roster.isLocked(type) ||
            oldDelegate.roster.figuresOf(type) != roster.figuresOf(type),
      );

  @override
  bool? hitTest(Offset position) => false;
}
