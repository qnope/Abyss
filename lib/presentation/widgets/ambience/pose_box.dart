import 'package:flutter/widgets.dart';

import 'sprite_motion.dart';

/// Paints [child], a box of [size], in the pose [pose] returns, asked
/// again each time [repaint] notifies.
///
/// The motion only repaints: nothing is rebuilt nor laid out, the child's
/// picture is reused from frame to frame, and the box's own repaint
/// boundary keeps the rest of the screen out of it. The child may
/// overflow its box while posed; it is never clipped.
class PoseBox extends StatelessWidget {
  final Size size;

  /// Tells when the pose changes, e.g. an ambience clock or an animation.
  final Listenable repaint;

  /// The pose of the child right now.
  final SpriteMotion Function() pose;

  final Widget child;

  const PoseBox({
    super.key,
    required this.size,
    required this.repaint,
    required this.pose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Flow(
      clipBehavior: Clip.none,
      delegate: _PoseDelegate(size: size, pose: pose, repaint: repaint),
      children: [child],
    ),
  );
}

class _PoseDelegate extends FlowDelegate {
  final Size size;
  final SpriteMotion Function() pose;

  _PoseDelegate({
    required this.size,
    required this.pose,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  Size getSize(BoxConstraints constraints) => constraints.constrain(size);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tight(size);

  @override
  void paintChildren(FlowPaintingContext context) =>
      context.paintChild(0, transform: pose().matrixFor(Offset.zero & size));

  @override
  bool shouldRelayout(_PoseDelegate oldDelegate) => oldDelegate.size != size;

  @override
  bool shouldRepaint(_PoseDelegate oldDelegate) =>
      oldDelegate.size != size || oldDelegate.pose != pose;
}
