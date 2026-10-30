import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_island_colors.dart';
import '../base/base_drawing.dart';
import '../base/base_pad_tier.dart';
import 'army_squad_geometry.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the banner of a squad as on the
/// mockup: a metal pole topped with a golden finial, a crossbar and a
/// pennant in the squad's colour carrying the unit's portrait. While the
/// unit is locked, the whole banner stands faint, its portrait greyed:
/// every part drawn at a lower alpha, never through a layer.
class ArmyBannerDrawer {
  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _greyed =
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = AbyssIslandColors.degraded
        ..color = const Color.fromRGBO(
          0,
          0,
          0,
          AbyssArmyColors.lockedBannerOpacity,
        );

  /// Draws the banner of [type] with its [portrait], [locked] or not.
  void paint(
    Canvas canvas,
    UnitType type,
    ui.Image? portrait, {
    required bool locked,
  }) {
    final alpha = locked ? AbyssArmyColors.lockedBannerOpacity : 1.0;
    Color faded(Color colour) => colour.withValues(alpha: colour.a * alpha);
    final edge = faded(AbyssArmyColors.bannerEdge);
    final foot = ArmySquadGeometry.bannerFoot(type, locked: locked);
    final top = ArmySquadGeometry.poleTop(foot);
    final colour = faded(AbyssArmyColors.of(type));
    canvas.drawOval(
      Rect.fromCenter(
        center: foot.translate(2 * _u, 0),
        width: 10 * _u,
        height: 4 * _u,
      ),
      Paint()..color = faded(AbyssArmyColors.bannerShadow),
    );
    final pole = RRect.fromRectAndRadius(
      Rect.fromLTRB(top.dx - 1.3 * _u, top.dy, top.dx + 1.3 * _u, foot.dy),
      const Radius.circular(_u),
    );
    canvas
      ..drawRRect(
        pole,
        Paint()
          ..shader = ui.Gradient.linear(
            pole.outerRect.centerLeft,
            pole.outerRect.centerRight,
            AbyssArmyColors.poleMetal.map(faded).toList(),
            const [0, .5, 1],
          ),
      )
      ..drawRRect(pole, _stroke(edge, .6))
      ..drawCircle(
        top.translate(0, -1.5 * _u),
        2.6 * _u,
        Paint()..color = faded(AbyssArmyColors.finial),
      )
      ..drawCircle(top.translate(0, -1.5 * _u), 2.6 * _u, _stroke(edge, .6));
    const half = ArmySquadGeometry.pennantWidth / 2;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        top.dx - half - 2 * _u,
        top.dy + 2 * _u,
        2 * half + 4 * _u,
        2.2 * _u,
      ),
      const Radius.circular(_u),
    );
    canvas
      ..drawRRect(bar, Paint()..color = faded(AbyssArmyColors.crossbar))
      ..drawRRect(bar, _stroke(edge, .5));
    final flag = _pennant(top);
    canvas
      ..drawPath(flag, Paint()..color = faded(AbyssArmyColors.pennantOf(type)))
      ..drawPath(flag, _stroke(edge, .8));
    for (final side in [-1, 1]) {
      final x = top.dx + side * (half - 2 * _u);
      canvas.drawLine(
        Offset(x, top.dy + 4 * _u),
        Offset(x, top.dy + 2 * _u + ArmySquadGeometry.pennantHeight),
        _stroke(colour.withValues(alpha: .9 * colour.a), 1.2),
      );
    }
    drawWholeImage(
      canvas,
      portrait,
      Rect.fromLTWH(top.dx - 8.5 * _u, top.dy + 7.5 * _u, 17 * _u, 17 * _u),
      locked ? _greyed : _image,
    );
    canvas.drawPath(
      _sheen(top),
      Paint()..color = faded(AbyssArmyColors.pennantSheen),
    );
  }

  /// The pennant hanging from the crossbar of a pole topped at [top], its
  /// bottom notched.
  static Path _pennant(Offset top) {
    const half = ArmySquadGeometry.pennantWidth / 2;
    final from = top.dy + 4 * _u, to = from + ArmySquadGeometry.pennantHeight;
    return polygonOf([
      Offset(top.dx - half, from),
      Offset(top.dx + half, from),
      Offset(top.dx + half, to),
      Offset(top.dx, to - 6 * _u),
      Offset(top.dx - half, to),
    ]);
  }

  /// The lit left half of the pennant.
  static Path _sheen(Offset top) {
    const half = ArmySquadGeometry.pennantWidth / 2;
    final from = top.dy + 4 * _u, to = from + ArmySquadGeometry.pennantHeight;
    return polygonOf([
      Offset(top.dx - half, from),
      Offset(top.dx, from),
      Offset(top.dx, to - 6 * _u),
      Offset(top.dx - half, to),
    ]);
  }

  static Paint _stroke(Color colour, double width) =>
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * _u
        ..color = colour;
}
