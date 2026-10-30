import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_colors.dart';
import '../base/base_drawing.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import 'army_crate_drawer.dart';
import 'army_layout.dart';

const _u = basePadUnit;

/// Draws, in projection coordinates, the supplies stacked in the front
/// block of the parade ground, as on the mockup: a lamp post at the back,
/// three crates (one on another) and a rack of four harpoons.
class ArmyDepotDrawer {
  final _crates = ArmyCrateDrawer();
  final _shaft = Paint()
    ..strokeWidth = 1.8 * _u
    ..color = AbyssArmyColors.harpoonShaft;
  final _tip = Paint()..color = AbyssArmyColors.harpoonTip;
  final _frame = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = .8 * _u
    ..color = AbyssArmyColors.lampFrame;

  /// Draws the depot at [ArmyLayout.depot].
  void paint(Canvas canvas) {
    Offset at(double du, double dv) => baseGroundToProjection(
        ArmyLayout.depot + Offset(du, dv));
    _lamp(canvas, at(-.9, -.9));
    final crates = at(-.2, .5);
    _crates
      ..paint(canvas, crates, 13 * _u, 12 * _u, ArmyCrateDrawer.wood)
      ..paint(canvas, crates.translate(15 * _u, 6 * _u), 10 * _u, 10 * _u,
          ArmyCrateDrawer.steel)
      ..paint(canvas, crates.translate(_u, -12 * _u), 9 * _u, 9 * _u,
          ArmyCrateDrawer.dark);
    _rack(canvas, at(.7, -.5));
  }

  void _lamp(Canvas canvas, Offset foot) {
    final pole = Rect.fromLTWH(foot.dx - 1.2 * _u, foot.dy - 34 * _u,
        2.4 * _u, 34 * _u);
    canvas.drawRect(
      pole,
      Paint()
        ..shader = ui.Gradient.linear(pole.centerLeft, pole.centerRight,
            AbyssArmyColors.poleMetal, const [0, .5, 1]),
    );
    paintGlow(canvas, foot.translate(0, -36 * _u), 9 * _u,
        AbyssColors.biolumCyan);
    final lamp = RRect.fromRectAndRadius(
      Rect.fromLTWH(foot.dx - 3 * _u, foot.dy - 40 * _u, 6 * _u, 7 * _u),
      const Radius.circular(2 * _u),
    );
    canvas
      ..drawRRect(lamp, Paint()..color = AbyssArmyColors.lampGlass)
      ..drawRRect(lamp, _frame);
  }

  void _rack(Canvas canvas, Offset foot) {
    for (var k = 0; k < 4; k++) {
      final base = foot.translate(-8 * _u + k * 5 * _u, k * 2 * _u);
      final top = base.translate(3 * _u, -30 * _u);
      canvas
        ..drawLine(base, top, _shaft)
        ..drawPath(
            polygonOf([
              top,
              top.translate(-1.5 * _u, -6 * _u),
              top.translate(2 * _u, -_u),
            ]),
            _tip);
    }
    final bar = Rect.fromLTWH(
        foot.dx - 10 * _u, foot.dy - 14 * _u, 22 * _u, 2.4 * _u);
    canvas
      ..save()
      ..translate(foot.dx, foot.dy)
      ..rotate(10 * pi / 180)
      ..translate(-foot.dx, -foot.dy)
      ..drawRect(bar, Paint()..color = AbyssArmyColors.rackBar)
      ..drawRect(
          bar,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = .5 * _u
            ..color = AbyssArmyColors.crateEdge)
      ..restore();
  }
}
