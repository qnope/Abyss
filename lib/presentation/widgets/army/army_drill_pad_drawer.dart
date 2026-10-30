import 'dart:math';

import 'package:flutter/painting.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_island_colors.dart';
import '../base/base_drawing.dart';
import '../base/base_label_text.dart';
import '../base/base_pad_drawer.dart';
import '../base/base_pad_geometry.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot.dart';
import '../base/base_slot_projection.dart';
import '../map/map_projection.dart';
import 'army_slots.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the drill pad of a squad: the base's
/// riveted deck lit in the squad's colour (see [BasePadDrawer]), its
/// plates seamed both ways, scuffed by boots, a ring painted in the
/// middle; or, while the barracks is too low for the unit, the base's
/// surveyed plot with its four glowing stakes. Its paints are made once
/// and reused for every pad.
class ArmyDrillPadDrawer {
  /// The deck a drill pad is laid as.
  static const tier = BasePadTier.deck;

  /// Plates of a pad along each side.
  static const plates = 5;

  /// Radius of the painted ring, as a share of the pad's side.
  static const ringRatio = .3;

  final _pads = BasePadDrawer();
  final _seam = Paint()
    ..strokeWidth = .6 * _u
    ..color = AbyssIslandColors.seam.withValues(alpha: .55);
  final _scuff = Paint()..color = AbyssArmyColors.scuff.withValues(alpha: .5);

  /// Draws the drill pad of [type], laid if [unlocked], else surveyed.
  void paint(Canvas canvas, UnitType type, {required bool unlocked}) {
    final slot = ArmySlots.pad(type), colour = AbyssArmyColors.of(type);
    if (!unlocked) {
      _pads.paint(canvas, slot, BasePadTier.plot, colour);
      return;
    }
    _pads.paint(canvas, slot, tier, colour);
    _seams(canvas, slot);
    _scuffs(canvas, slot, Random(type.index));
    _ring(canvas, slot, colour);
  }

  /// The ground point [du], [dv] cells from the middle of [slot], on its
  /// deck.
  Offset _onDeck(BaseSlot slot, double du, double dv) =>
      baseGroundToProjection(Offset(slot.u + du, slot.v + dv))
          .translate(0, -tier.lift);

  /// The seams across the deck's plates: the base's deck seams them
  /// along one side, a drill pad along the other too.
  void _seams(Canvas canvas, BaseSlot slot) {
    final edge = slot.footprint / 2 - BasePadGeometry.padInset;
    for (var m = 1; m < plates; m++) {
      final a = -edge + 2 * edge * m / plates;
      canvas.drawLine(
          _onDeck(slot, -edge, a), _onDeck(slot, edge, a), _seam);
    }
  }

  void _scuffs(Canvas canvas, BaseSlot slot, Random random) {
    final reach = slot.footprint / 2.6;
    for (var k = 0; k < 6; k++) {
      final at = _onDeck(slot, random.between(-reach, reach),
          random.between(-reach, reach));
      canvas.drawOval(
        Rect.fromCenter(
            center: at, width: 2 * random.between(3, 6) * _u, height: 2.4 * _u),
        _scuff,
      );
    }
  }

  void _ring(Canvas canvas, BaseSlot slot, Color colour) {
    final side = 2 * ringRatio * slot.footprint;
    final ring = Rect.fromCenter(
      center: slot.foot.translate(0, -tier.lift),
      width: side * MapProjection.tileWidth,
      height: side * MapProjection.tileHeight,
    );
    final inner = Rect.fromCenter(
        center: ring.center, width: .82 * ring.width, height: .82 * ring.height);
    canvas
      ..drawOval(ring, Paint()..color = colour.withValues(alpha: .1))
      ..drawOval(ring, _stroke(colour, .55, 1.6))
      ..drawPath(dashedPathOf(Path()..addOval(inner), 4 * _u, 3 * _u),
          _stroke(colour, .3, .8));
  }

  static Paint _stroke(Color colour, double alpha, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * _u
    ..color = colour.withValues(alpha: alpha);
}
