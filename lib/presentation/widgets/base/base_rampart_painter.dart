import 'package:flutter/rendering.dart';

import 'base_fit.dart';
import 'base_rampart.dart';
import 'base_rampart_drawer.dart';

/// Paints the front edges of a coral [rampart] over the buildings of the
/// base seen through [fit]: low enough to leave them in sight, open
/// before the citadel. The back edges lie in the still island.
///
/// Nothing in it moves: in its own repaint boundary, it is painted once
/// and only repainted when the rampart grows or the [fit] changes.
class BaseRampartPainter extends CustomPainter {
  final BaseRampart rampart;
  final BaseFit fit;

  const BaseRampartPainter({required this.rampart, required this.fit});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    fit.apply(canvas);
    paintBaseRampart(canvas, rampart.front);
    canvas.restore();
  }

  @override
  bool shouldRepaint(BaseRampartPainter oldDelegate) =>
      oldDelegate.rampart != rampart || oldDelegate.fit != fit;

  @override
  bool? hitTest(Offset position) => false;
}
