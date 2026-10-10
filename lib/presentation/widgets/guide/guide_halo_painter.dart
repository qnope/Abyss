import 'package:flutter/widgets.dart';

import '../../theme/abyss_colors.dart';

/// Halo of a [pulse] from 0 to 1 around a box, shrunk by [inset]: a circle,
/// or a rectangle rounded by [radius]. Repaints on each beat of [pulse]
/// alone, without rebuilding anything.
///
/// The halo comes in two layers, so that what it surrounds stays sharp:
/// the soft [glow], painted behind the child and only outside its shape,
/// and the crisp outline, painted in front, just outside that shape.
class GuideHaloPainter extends CustomPainter {
  final Animation<double> pulse;
  final BoxShape shape;
  final double radius;
  final EdgeInsets inset;

  /// The soft glow when true, the crisp outline when false.
  final bool glow;

  GuideHaloPainter({
    required this.pulse,
    required this.shape,
    required this.radius,
    required this.inset,
    required this.glow,
  }) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = pulse.value;
    final Rect box = inset.deflateRect(Offset.zero & size);
    final RRect edge = RRect.fromRectAndRadius(
      box,
      Radius.circular(shape == BoxShape.circle ? box.shortestSide / 2 : radius),
    );
    final RRect outline = edge.inflate(2);
    final Color cyan = AbyssColors.biolumCyan;
    if (!glow) {
      canvas.drawRRect(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = cyan.withValues(alpha: 0.55 + 0.45 * t),
      );
      return;
    }
    canvas.save();
    canvas.clipPath(_outside(edge));
    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 + 5 * t
        ..color = cyan.withValues(alpha: 0.35 + 0.45 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 5 * t),
    );
    canvas.restore();
  }

  /// Everything around [edge] the glow can reach, [edge] cut out.
  static Path _outside(RRect edge) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(edge.outerRect.inflate(40))
    ..addRRect(edge);

  @override
  bool shouldRepaint(GuideHaloPainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.shape != shape ||
      oldDelegate.radius != radius ||
      oldDelegate.inset != inset ||
      oldDelegate.glow != glow;
}
