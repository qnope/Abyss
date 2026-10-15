import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_colors.dart';
import '../../theme/abyss_motion.dart';

/// One bubble at one instant, as fractions turned into pixels.
typedef Bubble = ({Offset center, double radius, double opacity});

/// A few bubbles rising through their box and fading out at the top, e.g.
/// over a working building.
///
/// Where each bubble starts, its size and its delay come from [seed]
/// alone, so a building always bubbles the same way. Driven by the seconds
/// of a shared ambience [clock]; one paint, made once, is reused for every
/// bubble. It never takes a tap.
class BubblesPainter extends CustomPainter {
  static const defaultCount = 3;

  /// Seconds of the shared ambience clock.
  final ValueListenable<double> clock;
  final int seed;
  final int count;
  final Color color;

  final List<({double x, double size, double delay})> _seeds;
  final Paint _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

  static const _bottom = 0.85;
  static const _wobble = 0.04;

  BubblesPainter({
    required this.clock,
    required this.seed,
    this.count = defaultCount,
    this.color = AbyssColors.abyssMist,
  }) : _seeds = _scatter(seed, count),
       super(repaint: clock);

  static List<({double x, double size, double delay})> _scatter(
    int seed,
    int count,
  ) {
    final random = math.Random(seed);
    return [
      for (var i = 0; i < count; i++)
        (
          x: 0.2 + 0.6 * random.nextDouble(),
          size: 0.03 + 0.03 * random.nextDouble(),
          delay: (i + random.nextDouble() * 0.5) / count,
        ),
    ];
  }

  static final double _cycleSeconds =
      AbyssMotion.bubbleCycle.inMicroseconds / 1e6;

  /// The bubbles at [seconds] in a box of [size].
  List<Bubble> bubblesAt(double seconds, Size size) => [
    for (final s in _seeds) _bubble(s, seconds, size),
  ];

  Bubble _bubble(
    ({double x, double size, double delay}) s,
    double seconds,
    Size size,
  ) {
    final turn = seconds / _cycleSeconds + s.delay;
    final t = turn - turn.floorToDouble();
    final sway = _wobble * math.sin(2 * math.pi * (2 * t + s.delay));
    final radius = math.max(0.5, s.size * size.shortestSide * (0.6 + 0.4 * t));
    return (
      center: Offset(
        (s.x + sway) * size.width,
        size.height * _bottom * (1 - t) + radius,
      ),
      radius: radius,
      opacity: math.sin(math.pi * t),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final seconds = clock.value;
    for (final s in _seeds) {
      final bubble = _bubble(s, seconds, size);
      _paint.color = color.withValues(alpha: color.a * bubble.opacity);
      canvas.drawCircle(bubble.center, bubble.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) =>
      oldDelegate.clock != clock ||
      oldDelegate.seed != seed ||
      oldDelegate.count != count ||
      oldDelegate.color != color;

  @override
  bool? hitTest(Offset position) => false;
}
