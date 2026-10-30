import 'dart:math';

import 'package:flutter/painting.dart';

import '../../theme/abyss_island_colors.dart';
import 'base_deck_drawer.dart';
import 'base_drawing.dart';
import 'base_pad_geometry.dart';
import 'base_pad_slab.dart';
import 'base_pad_tier.dart';
import 'base_slot.dart';
import 'base_slot_projection.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the pad of a building at its tier:
/// a surveyed plot with its stakes, a gravel slab, or a riveted deck lit
/// in the building's colour. Its paints are made once and reused.
class BasePadDrawer {
  final _plotFill =
      Paint()..color = AbyssIslandColors.plot.withValues(alpha: .05);
  final _plotLine =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 * _u
        ..color = AbyssIslandColors.plot.withValues(alpha: .55);
  final _stakeShadow =
      Paint()..color = AbyssIslandColors.stakeShadow.withValues(alpha: .6);
  final _stake = Paint()..color = AbyssIslandColors.stake;
  final _lampCore = Paint()..color = AbyssIslandColors.lampCore;
  final _gravelRim =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _u
        ..color = AbyssIslandColors.gravelRim.withValues(alpha: .35);
  final _pebble = Paint();
  final _deck = BaseDeckDrawer();

  /// Draws the pad of [slot] at [tier], lit in [colour]; [seed] scatters
  /// its gravel the same way every time.
  void paint(
    Canvas canvas,
    BaseSlot slot,
    BasePadTier tier,
    Color colour, {
    int seed = 0,
  }) {
    switch (tier) {
      case BasePadTier.plot:
        _plot(canvas, slot);
      case BasePadTier.gravel:
        _gravel(canvas, slot, Random(seed));
      case BasePadTier.deck || BasePadTier.litDeck:
        _deck.paint(canvas, slot, tier, colour);
    }
  }

  /// A surveyed plot: a dashed outline and a stake at each corner.
  void _plot(Canvas canvas, BaseSlot slot) {
    final corners = slot.padCorners;
    canvas
      ..drawPath(polygonOf(corners), _plotFill)
      ..drawPath(dashedPolygonOf(corners, 5 * _u, 4 * _u), _plotLine);
    final tips = slot.stakeTips;
    for (var k = 0; k < corners.length; k++) {
      final foot = corners[k], tip = tips[k];
      canvas
        ..drawOval(
          Rect.fromCenter(
            center: foot.translate(0, _u),
            width: 6 * _u,
            height: 2.8 * _u,
          ),
          _stakeShadow,
        )
        ..drawRect(
          Rect.fromLTWH(
            foot.dx - .9 * _u,
            foot.dy - BasePadGeometry.stakeHeight,
            1.8 * _u,
            BasePadGeometry.stakeHeight,
          ),
          _stake,
        );
      paintGlow(canvas, tip, 4 * _u, AbyssIslandColors.plot);
      canvas.drawCircle(tip, 1.3 * _u, _lampCore);
    }
  }

  /// A gravel slab strewn with pebbles, its back rim catching the light.
  void _gravel(Canvas canvas, BaseSlot slot, Random random) {
    const tier = BasePadTier.gravel;
    paintPadSlab(canvas, slot, tier, const [
      AbyssIslandColors.gravelLight,
      AbyssIslandColors.gravelDark,
    ]);
    final n = slot.footprint, reach = n / 2 - .15;
    for (var k = 0; k < 14 * n; k++) {
      final at = baseGroundToProjection(
        Offset(
          slot.u + random.between(-reach, reach),
          slot.v + random.between(-reach, reach),
        ),
      ).translate(0, -tier.lift);
      final r = random.between(.8, 1.8) * _u;
      _pebble.color =
          Color.lerp(
            AbyssIslandColors.pebbleLight,
            AbyssIslandColors.pebbleDark,
            random.nextDouble(),
          )!;
      canvas.drawOval(
        Rect.fromCenter(center: at, width: 2 * r, height: 1.2 * r),
        _pebble,
      );
    }
    final [top, right, _, left] = slot.padTop(tier);
    canvas.drawPath(
      Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(top.dx, top.dy)
        ..lineTo(right.dx, right.dy),
      _gravelRim,
    );
  }
}
