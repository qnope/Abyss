import 'dart:ui';

import '../../../domain/unit/unit_type.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import 'army_drill_pad_drawer.dart';
import 'army_layout.dart';
import 'squad_slots.dart';

const _u = basePadUnit;

/// Where a squad stands on the parade ground, in projection coordinates,
/// as on the mockup: its figures, their shadows, its banner and its
/// plaque. A locked squad stands on its plot, any other on its deck.
abstract final class ArmySquadGeometry {
  /// Projection units per pixel of a figure's 120 x 150 drawing.
  static const figureScale = .36 * _u;

  /// A figure on the ground, and where its feet lie in it.
  static const figureSize = Size(120 * figureScale, 150 * figureScale);
  static const figureFeet = Offset(60 * figureScale, 140 * figureScale);

  /// The banner: the height of its pole, the size of its pennant.
  static const poleHeight = 54 * _u;
  static const pennantWidth = 22 * _u;
  static const pennantHeight = 30 * _u;

  /// How far above the front tip of its pad a plaque floats.
  static const plaqueRise = 3 * _u;

  /// How far the ground of a squad lies above the island.
  static double liftOf({required bool locked}) =>
      (locked ? BasePadTier.plot : ArmyDrillPadDrawer.tier).lift;

  /// The ground point [cell] of a squad, lifted on its pad.
  static Offset _onPad(Offset cell, bool locked) =>
      baseGroundToProjection(cell).translate(0, -liftOf(locked: locked));

  /// The feet of the first [figures] of the squad of [type], back to
  /// front.
  static List<Offset> feetOf(
    UnitType type,
    int figures, {
    required bool locked,
  }) => [
    for (final figure in SquadSlots.figuresBackToFront(figures))
      feetAt(type, figure, locked: locked),
  ];

  /// The feet of the figure on slot [figure] of the squad of [type].
  static Offset feetAt(UnitType type, int figure, {required bool locked}) =>
      _onPad(ArmyLayout.padCentre(type) + SquadSlots.arrival[figure], locked);

  /// The box of a figure standing on [feet].
  static Rect figureBox(Offset feet) => (feet - figureFeet) & figureSize;

  /// The part of [figureBox] above its [feet], which a pose turns and
  /// grows around: its bottom on the deck.
  static Rect bodyBox(Offset feet) {
    final box = figureBox(feet);
    return Rect.fromLTRB(box.left, box.top, box.right, feet.dy);
  }

  /// The contact shadow laid under a figure standing on [feet].
  static Rect shadowBox(Offset feet) => Rect.fromCenter(
    center: feet.translate(1.5 * _u, 0),
    width: 22 * _u,
    height: 8 * _u,
  );

  /// The foot of the pole of the banner of [type].
  static Offset bannerFoot(UnitType type, {required bool locked}) =>
      _onPad(ArmyLayout.bannerAt(type), locked);

  /// The top of the pole standing on [foot].
  static Offset poleTop(Offset foot) => foot.translate(0, -poleHeight);

  /// The box of the banner standing on [foot]: its pole, its crossbar and
  /// its pennant.
  static Rect bannerBox(Offset foot) {
    final top = poleTop(foot);
    return Rect.fromLTRB(
      top.dx - pennantWidth / 2 - 2 * _u,
      top.dy - 4 * _u,
      top.dx + pennantWidth / 2 + 2 * _u,
      foot.dy,
    );
  }

  /// The centre of the plaque of [type]: at the front tip of its pad.
  static Offset plaqueAt(UnitType type) {
    const inset = ArmyLayout.padSize / 2 - .2;
    return baseGroundToProjection(
      ArmyLayout.padCentre(type) + const Offset(inset, inset),
    ).translate(0, -plaqueRise);
  }
}
