import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_army_colors.dart';
import '../../theme/abyss_colors.dart';
import '../base/base_drawing.dart';
import '../base/base_pad_tier.dart';

const _u = basePadUnit;

/// The look of a supply crate: its lit side, its top and the paint mark
/// on its side, if any.
typedef ArmyCrateLook = ({Color side, Color top, Color? mark});

/// Draws, in projection coordinates, an isometric supply crate of the
/// depot standing on a point, as on the mockup: its soft shadow, two
/// sides (the right one in shade), its top, a strap and a lit edge.
class ArmyCrateDrawer {
  static const wood = (
    side: AbyssArmyColors.crateWood,
    top: AbyssArmyColors.crateWoodTop,
    mark: AbyssArmyColors.markOrange,
  );
  static const steel = (
    side: AbyssArmyColors.crateSteel,
    top: AbyssArmyColors.crateSteelTop,
    mark: AbyssArmyColors.markYellow,
  );
  static const dark = (
    side: AbyssArmyColors.crateDark,
    top: AbyssArmyColors.crateDarkTop,
    mark: null,
  );

  final _edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = .7 * _u
    ..color = AbyssArmyColors.crateEdge;
  final _strap = Paint()
    ..strokeWidth = 1.2 * _u
    ..color = AbyssArmyColors.crateStrap;
  final _sheen = Paint()
    ..strokeWidth = .7 * _u
    ..color = AbyssColors.daylight.withValues(alpha: .25);

  /// Draws a crate of [look], [half] wide on each side of its [foot] and
  /// [height] tall.
  void paint(Canvas canvas, Offset foot, double half, double height,
      ArmyCrateLook look) {
    final t = foot.translate(0, -half / 2), r = foot.translate(half, 0);
    final b = foot.translate(0, half / 2), l = foot.translate(-half, 0);
    Offset up(Offset p) => p.translate(0, -height);
    final shadow = Rect.fromCenter(
        center: foot.translate(.2 * half, .3 * half),
        width: 2.4 * half,
        height: half);
    canvas.drawOval(
      shadow,
      Paint()
        ..shader = ui.Gradient.radial(shadow.center, shadow.width / 2, [
          AbyssArmyColors.crestShadow.withValues(alpha: .55),
          AbyssArmyColors.crestShadow.withValues(alpha: 0),
        ]),
    );
    final shade = Color.lerp(look.side, AbyssArmyColors.crateEdge, .45)!;
    for (final (face, colour) in [
      ([l, b, up(b), up(l)], look.side),
      ([b, r, up(r), up(b)], shade),
      ([up(t), up(r), up(b), up(l)], look.top),
    ]) {
      final path = polygonOf(face);
      canvas
        ..drawPath(path, Paint()..color = colour)
        ..drawPath(path, _edge);
    }
    canvas
      ..drawLine(l.translate(.1 * half, -.5 * height + .05 * half),
          b.translate(0, -.5 * height), _strap)
      ..drawLine(up(l), up(t), _sheen);
    final mark = look.mark;
    if (mark == null) return;
    final middle = Offset.lerp(l, b, .5)!.translate(0, -.55 * height);
    canvas.drawLine(
      middle.translate(-.25 * half, -.05 * half),
      middle.translate(.25 * half, .2 * half),
      Paint()
        ..strokeWidth = 2 * _u
        ..strokeCap = StrokeCap.round
        ..color = mark,
    );
  }
}
