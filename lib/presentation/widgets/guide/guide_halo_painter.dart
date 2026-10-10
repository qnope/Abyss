import 'package:flutter/widgets.dart';

import '../../theme/abyss_colors.dart';

/// Glow of a [pulse] from 0 to 1 around a box, shrunk by [inset]: a circle,
/// or a rectangle rounded by [radius]. Repaints on each beat of [pulse]
/// alone, without rebuilding anything.
class GuideHaloPainter extends CustomPainter {
  final Animation<double> pulse;
  final BoxShape shape;
  final double radius;
  final EdgeInsets inset;

  GuideHaloPainter({
    required this.pulse,
    required this.shape,
    required this.radius,
    required this.inset,
  }) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = pulse.value;
    final Rect box = inset.deflateRect(Offset.zero & size);
    final RRect outline = RRect.fromRectAndRadius(
      box,
      Radius.circular(shape == BoxShape.circle ? box.shortestSide / 2 : radius),
    ).inflate(2);
    final Color cyan = AbyssColors.biolumCyan;
    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 + 5 * t
        ..color = cyan.withValues(alpha: 0.35 + 0.45 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 5 * t),
    );
    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = cyan.withValues(alpha: 0.55 + 0.45 * t),
    );
  }

  @override
  bool shouldRepaint(GuideHaloPainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.shape != shape ||
      oldDelegate.radius != radius ||
      oldDelegate.inset != inset;
}
