import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import 'rise_motion.dart';

/// The glow drifting up from a rising sprite (see [RiseMotion]): two
/// soft discs of [color] whose opacity, set on reused paints, fades as
/// [progress] goes from 0 to 1. Draws nothing at rest; never takes a tap.
class RiseGlowPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;

  final Paint _halo = Paint();
  final Paint _core = Paint();

  static const _haloShare = 0.35;
  static const _climb = 0.4;

  RiseGlowPainter({required this.progress, required this.color})
    : super(repaint: progress);

  /// Centre of the glow at [t] over a sprite of [size].
  static Offset centerAt(double t, Size size) =>
      Offset(size.width / 2, size.height * (0.5 - _climb * t));

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final glow = RiseMotion.at(t).glow;
    if (glow <= 0 || size.isEmpty) return;
    final center = centerAt(t, size);
    final radius = size.shortestSide / 2;
    _halo.color = color.withValues(alpha: color.a * glow * _haloShare);
    _core.color = color.withValues(alpha: color.a * glow);
    canvas
      ..drawCircle(center, radius, _halo)
      ..drawCircle(center, radius / 2, _core);
  }

  @override
  bool shouldRepaint(RiseGlowPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;

  @override
  bool? hitTest(Offset position) => false;
}
