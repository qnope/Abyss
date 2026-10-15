import 'package:flutter/widgets.dart';

import 'ambience_clock_scope.dart';
import 'ambient_motion.dart';
import 'pose_box.dart';

/// Keeps [child], a box of [size], gently moving with [motion], shifted
/// by [phase], on the clock of the nearest [AmbienceClockScope].
///
/// Without a scope, or with a still motion, the child is shown as is.
/// Many poses under one scope share its single clock, and each tick only
/// repaints the child (see [PoseBox]).
class AmbientPose extends StatelessWidget {
  final AmbientMotion motion;

  /// Fraction of the cycle this child is ahead, e.g. from
  /// [AmbientMotion.phaseOf], so neighbours do not move in step.
  final double phase;

  final Size size;
  final Widget child;

  const AmbientPose({
    super.key,
    required this.motion,
    required this.size,
    required this.child,
    this.phase = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (motion == AmbientMotion.still) return child;
    final clock = AmbienceClockScope.maybeOf(context);
    if (clock == null) return child;
    return PoseBox(
      size: size,
      repaint: clock,
      pose: () => motion.at(clock.value, phase: phase),
      child: child,
    );
  }
}
