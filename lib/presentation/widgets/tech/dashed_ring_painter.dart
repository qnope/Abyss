import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a dashed circle inscribed in the canvas, used to highlight
/// the next reachable node of a tree.
class DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const DashedRingPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashCount = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - strokeWidth / 2,
    );
    final step = 2 * math.pi / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * step, step * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
