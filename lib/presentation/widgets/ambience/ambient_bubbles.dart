import 'package:flutter/widgets.dart';

import 'ambience_clock_scope.dart';
import 'bubbles_painter.dart';

/// Bubbles rising through the box this widget fills, on the clock of the
/// nearest [AmbienceClockScope]; nothing without one.
///
/// Never takes a tap and repaints within its own boundary.
class AmbientBubbles extends StatelessWidget {
  /// Picks where the bubbles rise (see [BubblesPainter.seed]).
  final int seed;

  const AmbientBubbles({super.key, required this.seed});

  @override
  Widget build(BuildContext context) {
    final clock = AmbienceClockScope.maybeOf(context);
    if (clock == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: BubblesPainter(clock: clock, seed: seed)),
      ),
    );
  }
}
