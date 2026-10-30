import 'package:flutter/painting.dart';

import '../../theme/abyss_island_colors.dart';
import '../map/map_projection.dart';
import 'base_pad_geometry.dart';
import 'base_pad_slab.dart';
import 'base_pad_tier.dart';
import 'base_slot.dart';
import 'base_slot_projection.dart';

const _u = basePadUnit;

/// Draws a riveted metal deck, its front rim and lamps lit in the
/// building's colour; at [BasePadTier.litDeck], three corner beacons and
/// a glow pooled on the deck too.
class BaseDeckDrawer {
  final _seam =
      Paint()
        ..strokeWidth = .7 * _u
        ..color = AbyssIslandColors.seam.withValues(alpha: .7);
  final _rivet = Paint()..color = AbyssIslandColors.rivet;
  final _backRim =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9 * _u
        ..color = AbyssIslandColors.deckRim.withValues(alpha: .45);
  final _post = Paint()..color = AbyssIslandColors.deckLight;
  final _core = Paint()..color = AbyssIslandColors.beaconCore;

  /// Draws the deck of [slot] at [tier], lit in [colour].
  void paint(Canvas canvas, BaseSlot slot, BasePadTier tier, Color colour) {
    final lit = tier == BasePadTier.litDeck, lift = tier.lift;
    paintPadSlab(canvas, slot, tier, const [
      AbyssIslandColors.deckLight,
      AbyssIslandColors.deckMid,
      AbyssIslandColors.deckDark,
    ]);
    final n = slot.footprint, edge = n / 2 - BasePadGeometry.padInset;
    for (var m = 1; m < 2 * n; m++) {
      final a = -edge + 2 * edge * m / (2 * n);
      canvas.drawLine(
        baseGroundToProjection(
          Offset(slot.u + a, slot.v - edge),
        ).translate(0, -lift),
        baseGroundToProjection(
          Offset(slot.u + a, slot.v + edge),
        ).translate(0, -lift),
        _seam,
      );
    }
    final centre = slot.foot.translate(0, -lift);
    final corners = slot.padCorners, top = slot.padTop(tier);
    for (final corner in top) {
      canvas.drawCircle(Offset.lerp(corner, centre, .14)!, 1.1 * _u, _rivet);
    }
    final [ut, ur, ub, ul] = top;
    canvas
      ..drawPath(_line([ul, ub, ur]), _stroke(colour, lit ? .9 : .55, 1.4))
      ..drawPath(_line([ul, ut, ur]), _backRim);
    final lamp = Paint()..color = colour.withValues(alpha: .85);
    final [_, r, b, l] = corners;
    for (final (from, to) in [(l, b), (b, r)]) {
      for (var m = 1; m < 2 * n; m++) {
        final at = Offset.lerp(from, to, m / (2 * n))!.translate(0, -lift / 2);
        canvas.drawCircle(at, .9 * _u, lamp);
      }
    }
    if (lit) _beacons(canvas, slot, [ul, ut, ur], centre, colour);
  }

  void _beacons(
    Canvas canvas,
    BaseSlot slot,
    List<Offset> corners,
    Offset centre,
    Color colour,
  ) {
    final spread = .84 * slot.footprint;
    canvas.drawOval(
      Rect.fromCenter(
        center: centre,
        width: spread * MapProjection.tileWidth,
        height: spread * MapProjection.tileHeight,
      ),
      Paint()
        ..color = colour.withValues(alpha: .16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6 * _u),
    );
    final halo =
        Paint()
          ..color = colour.withValues(alpha: .35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2 * _u);
    for (final corner in corners) {
      final light = corner.translate(0, -8.5 * _u);
      canvas
        ..drawRect(
          Rect.fromLTWH(
            corner.dx - 1.1 * _u,
            corner.dy - 8 * _u,
            2.2 * _u,
            8 * _u,
          ),
          _post,
        )
        ..drawCircle(light, 5 * _u, halo)
        ..drawCircle(light, 1.5 * _u, _core);
    }
  }

  static Path _line(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  static Paint _stroke(Color colour, double alpha, double width) =>
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * _u
        ..color = colour.withValues(alpha: alpha);
}
