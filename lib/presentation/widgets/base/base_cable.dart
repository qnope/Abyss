import 'dart:math';
import 'dart:ui';

import '../../../domain/building/building_type.dart';
import '../../theme/abyss_island_colors.dart';
import 'base_drawing.dart';
import 'base_layout.dart';
import 'base_slot_projection.dart';

const _px = baseMockPixel;

/// The cable of the Descent module, hanging from the plateau's lip at
/// [top] (in projection coordinates) down into the dark of the trench,
/// a small lit cabin on it and a blue glow around it.
class BaseCable {
  /// How far past the module, along the lip, the cable hangs, in cells.
  static const offset = 0.8;

  /// Share of the drop down to the cabin.
  static const cabinShare = 0.62;

  /// Shortest drop drawn, in projection units.
  static const minDrop = 120 * _px;

  final Offset top;

  const BaseCable(this.top);

  /// The cable of [layout] once its Descent module is [built]: on the
  /// front edge nearest the module, a little past it; none before.
  static BaseCable? of(BaseLayout layout, Set<BuildingType> built) {
    const descent = BuildingType.descentModule;
    final slot = layout.slots[descent];
    if (slot == null || !built.contains(descent)) return null;
    final n = layout.size.toDouble();
    final lip = slot.u >= slot.v
        ? Offset(n, min(n, slot.v + offset))
        : Offset(min(n, slot.u + offset), n);
    return BaseCable(baseGroundToProjection(lip));
  }

  /// Where the cabin hangs on a cable reaching down to [bottom].
  Offset cabinAt(double bottom) {
    final from = top.dy + 4 * _px, to = max(bottom, top.dy + minDrop);
    return Offset(top.dx + 5 * _px, from + (to - from) * cabinShare);
  }

  /// Draws the cable down to [bottom], in projection coordinates: drawn
  /// before the slab, which hides it down to its foot.
  void paint(Canvas canvas, {required double bottom}) {
    final x = top.dx + 2 * _px, y = top.dy + 4 * _px;
    final end = max(bottom, top.dy + minDrop);
    final fall = Rect.fromLTRB(x, y, x + 8 * _px, end);
    for (final (dx, width, alpha) in [(0.0, 1.4, 1.0), (5.0, .9, .6)]) {
      canvas.drawLine(
        Offset(x + dx * _px, y),
        Offset(x + (dx + 2) * _px, end),
        verticalGradient(fall, [
          AbyssIslandColors.cable.withValues(alpha: alpha),
          AbyssIslandColors.cable.withValues(alpha: 0),
        ], const [0, 1])
          ..strokeWidth = width * _px,
      );
    }
    final cabin = cabinAt(bottom);
    _glow(canvas, cabin.translate(0, 30 * _px));
    final box = RRect.fromRectAndRadius(
        Rect.fromCenter(center: cabin, width: 12 * _px, height: 13 * _px),
        const Radius.circular(3 * _px));
    canvas
      ..drawRRect(box, Paint()..color = AbyssIslandColors.cabin)
      ..drawRRect(
          box,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _px
            ..color = AbyssIslandColors.cabinRim);
    canvas.drawCircle(cabin.translate(0, .5 * _px), 2.4 * _px,
        Paint()..color = AbyssIslandColors.cabinLight);
    canvas.drawPath(
      polygonOf([
        for (final (dx, dy) in [(-9, 8), (0, 3), (9, 8), (19, 70), (-19, 70)])
          cabin.translate(dx * _px, dy * _px),
      ]),
      Paint()..color = AbyssIslandColors.cabinBeam,
    );
  }

  /// The soft blue glow around the cabin, an upright ellipse.
  void _glow(Canvas canvas, Offset centre) {
    const radius = 40 * _px;
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(1, 1.5)
      ..drawCircle(Offset.zero, radius, Paint()
        ..shader = Gradient.radial(Offset.zero, radius, [
          AbyssIslandColors.deepGlow,
          AbyssIslandColors.deepGlow.withValues(alpha: 0),
        ]))
      ..restore();
  }
}
