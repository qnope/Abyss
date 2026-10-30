import 'dart:math';

import 'package:flutter/painting.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_army_colors.dart';
import '../ambience/sprite_motion.dart';
import '../base/base_drawing.dart';
import '../base/base_pad_tier.dart';
import 'army_squad_drawer.dart';
import 'army_squad_geometry.dart';
import 'squad_arrival.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, a recruit arriving on its squad's
/// drill pad at a progress from 0 to 1 (see [SquadArrival]): a faint
/// column of light full of rising bubbles over its slot, the recruit
/// falling down it, then the ring it lands with spreading on the deck.
/// The recruit that stays is the squad's own figure once landed (see
/// ArmySquadsPainter); one that joins the ranks melts away.
class ArmyArrivalDrawer {
  /// How high above its slot the recruit starts, in figure heights.
  static const drop = 2.4;

  /// Width of the column of light.
  static const columnWidth = 18 * _u;

  static const _bubbles = 7;

  final ArmySquadDrawer squads;
  final _bubble =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8 * _u;
  final _ring =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * _u;

  ArmyArrivalDrawer(this.squads);

  /// Draws the recruit of [arrival] on the pad of [type] at [t].
  void paint(Canvas canvas, UnitType type, SquadArrival arrival, double t) {
    final feet = ArmySquadGeometry.feetAt(type, arrival.figure, locked: false);
    final fall = SquadArrival.fallAt(t), spread = SquadArrival.ringAt(t);
    _column(canvas, feet, t, 1 - spread);
    final opacity = arrival.stays ? 1.0 : SquadArrival.fadeAt(t);
    if (opacity > 0 && (fall > 0 || !arrival.stays)) {
      squads.paintOne(
        canvas,
        type,
        feet,
        pose: SpriteMotion(dy: -drop * fall),
        opacity: opacity * (1 - .5 * fall),
        shadow: opacity > .5,
      );
    }
    if (spread > 0 && spread < 1) _landing(canvas, feet, spread);
  }

  /// The column of light over [feet] and its bubbles at [t], at [glow].
  void _column(Canvas canvas, Offset feet, double t, double glow) {
    if (glow <= 0) return;
    final height = ArmySquadGeometry.figureSize.height * (1 + drop);
    final column = Rect.fromLTRB(
      feet.dx - columnWidth / 2,
      feet.dy - height,
      feet.dx + columnWidth / 2,
      feet.dy,
    );
    const light = AbyssArmyColors.recruitColumn;
    canvas.drawRect(
      column,
      verticalGradient(
        column,
        [
          light.withValues(alpha: 0),
          light.withValues(alpha: .22 * glow),
          light.withValues(alpha: .08 * glow),
        ],
        const [0, .7, 1],
      ),
    );
    const bubble = AbyssArmyColors.recruitBubble;
    for (var k = 0; k < _bubbles; k++) {
      final rise = (k / _bubbles + 1.2 * t) % 1;
      _bubble.color = bubble.withValues(alpha: glow * sin(pi * rise));
      canvas.drawCircle(
        Offset(
          feet.dx + 3 * _u * sin(2.3 * k + 9 * t),
          feet.dy - rise * height,
        ),
        (1 + .6 * (k % 3)) * _u,
        _bubble,
      );
    }
  }

  /// The ring spreading from [feet], [spread] from 0 to 1.
  void _landing(Canvas canvas, Offset feet, double spread) {
    final width = (16 + 30 * spread) * _u;
    _ring.color = AbyssArmyColors.landingRing.withValues(alpha: 1 - spread);
    canvas.drawOval(
      Rect.fromCenter(center: feet, width: width, height: width / 2),
      _ring,
    );
  }
}
