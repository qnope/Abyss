import 'dart:math';
import 'dart:ui';

import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_pad_tier.dart';
import 'base_rampart_segment.dart';
import 'base_slot_projection.dart';

const _s = basePadUnit;

/// Draws [blocks] of a coral rampart, in projection coordinates and in
/// the order given (back to front): each block's face toward the viewer,
/// lit when it runs along u, its rounded top, two pores in its face and,
/// on one block in two, a polyp with a glowing tip.
void paintBaseRampart(Canvas canvas, List<BaseRampartSegment> blocks) {
  final pore = Paint()..color = AbyssIslandColors.coralPore;
  final polyp = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.2 * _s
    ..color = AbyssIslandColors.polyp;
  for (final block in blocks) {
    final random = Random(block.seed + (block.front ? 50 : 0));
    final up = Offset(0, -block.height);
    final (start, end) = block.face;
    final a = baseGroundToProjection(start), b = baseGroundToProjection(end);
    final face = polygonOf([a, b, b + up, a + up]);
    canvas.drawPath(
      face,
      verticalGradient(
        face.getBounds(),
        block.alongU
            ? AbyssIslandColors.coralLitFace
            : AbyssIslandColors.coralShadedFace,
        const [0, 1],
      ),
    );
    final top = [for (final c in block.ground) baseGroundToProjection(c) + up];
    final lid = polygonOf(top);
    canvas.drawPath(lid,
        verticalGradient(lid.getBounds(), AbyssIslandColors.coralTop,
            const [0, 1]));
    for (var k = 0; k < 2; k++) {
      final at = Offset.lerp(a, b, random.nextDouble())!
          .translate(0, -block.height * random.between(.2, .8));
      canvas.drawCircle(at, .7 * _s, pore);
    }
    if (random.nextDouble() < .5) _polyp(canvas, top, polyp);
  }
}

/// A polyp rising from the middle of a block's [top], its tip glowing.
void _polyp(Canvas canvas, List<Offset> top, Paint stroke) {
  final centre = top.reduce((a, b) => a + b) / top.length.toDouble();
  canvas.drawPath(
    Path()
      ..moveTo(centre.dx, centre.dy)
      ..relativeQuadraticBezierTo(-2 * _s, -4 * _s, -_s, -7 * _s)
      ..moveTo(centre.dx, centre.dy)
      ..relativeQuadraticBezierTo(2 * _s, -3 * _s, 3 * _s, -5 * _s),
    stroke,
  );
  paintGlow(canvas, centre.translate(-_s, -7 * _s), 2.4 * _s,
      AbyssIslandColors.polypGlow);
}
