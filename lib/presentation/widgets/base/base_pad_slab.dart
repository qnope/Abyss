import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_slot.dart';

/// Draws the raised plate of a pad at [tier]: its two front faces and its
/// top face, filled from its top left to its bottom right with [top].
void paintPadSlab(
  Canvas canvas,
  BaseSlot slot,
  BasePadTier tier,
  List<Color> top,
) {
  final [_, r, b, l] = slot.padCorners;
  final [ut, ur, ub, ul] = slot.padTop(tier);
  for (final (face, colours) in [
    (
      [l, b, ub, ul],
      const [AbyssIslandColors.padLitTop, AbyssIslandColors.padLitBottom],
    ),
    (
      [b, r, ur, ub],
      const [AbyssIslandColors.padShadedTop, AbyssIslandColors.padShadedBottom],
    ),
  ]) {
    final path = polygonOf(face);
    final box = path.getBounds();
    canvas.drawPath(path, verticalGradient(box, colours, const [0, 1]));
  }
  final face = polygonOf([ut, ur, ub, ul]);
  final box = face.getBounds();
  canvas.drawPath(
    face,
    Paint()
      ..shader = ui.Gradient.linear(box.topLeft, box.bottomRight, top, [
        for (var k = 0; k < top.length; k++) k / (top.length - 1),
      ]),
  );
}
