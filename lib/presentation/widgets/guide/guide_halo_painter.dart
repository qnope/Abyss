import 'package:flutter/widgets.dart';

import '../../theme/abyss_colors.dart';

/// Halo of a [pulse] from 0 to 1 around a box, shrunk by [inset]: a circle,
/// a rectangle rounded by [radius], or the [outline] traced in the box.
/// Repaints on each beat of [pulse] alone, without rebuilding anything.
///
/// The halo comes in two layers, so that what it surrounds stays sharp:
/// the soft [glow], painted behind the child and only outside its shape,
/// and the crisp outline, painted in front, just outside that shape.
class GuideHaloPainter extends CustomPainter {
  final Animation<double> pulse;
  final BoxShape shape;
  final double radius;
  final EdgeInsets inset;
  final Path Function(Rect box)? outline;

  /// The soft glow when true, the crisp outline when false.
  final bool glow;

  GuideHaloPainter({
    required this.pulse,
    required this.shape,
    required this.radius,
    required this.inset,
    this.outline,
    required this.glow,
  }) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = pulse.value;
    final Rect box = inset.deflateRect(Offset.zero & size);
    final Color cyan = AbyssColors.biolumCyan;
    if (!glow) {
      _line(
        canvas,
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = cyan.withValues(alpha: 0.55 + 0.45 * t),
      );
      return;
    }
    canvas.save();
    canvas.clipPath(_outside(box));
    _line(
      canvas,
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 + 5 * t
        ..color = cyan.withValues(alpha: 0.35 + 0.45 * t)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 5 * t),
    );
    canvas.restore();
  }

  /// The rounded box, or the circle, the halo surrounds in [box].
  RRect _rounded(Rect box) => RRect.fromRectAndRadius(
    box,
    Radius.circular(shape == BoxShape.circle ? box.shortestSide / 2 : radius),
  );

  /// Strokes the halo's line with [paint]: the [outline] itself, or just
  /// outside the rounded box.
  void _line(Canvas canvas, Rect box, Paint paint) {
    if (outline case final trace?) {
      canvas.drawPath(trace(box), paint);
    } else {
      canvas.drawRRect(_rounded(box).inflate(2), paint);
    }
  }

  /// Everything around the shape in [box] the glow can reach, the shape
  /// cut out.
  Path _outside(Rect box) {
    final Path around = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(box.inflate(40));
    if (outline case final trace?) return around..addPath(trace(box), Offset.zero);
    return around..addRRect(_rounded(box));
  }

  @override
  bool shouldRepaint(GuideHaloPainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.shape != shape ||
      oldDelegate.radius != radius ||
      oldDelegate.inset != inset ||
      oldDelegate.outline != outline ||
      oldDelegate.glow != glow;
}
