import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'parallax_layer.dart';
import 'trench_ridges_painter.dart';
import 'trench_water_painter.dart';

export 'trench_ridges_painter.dart';
export 'trench_water_painter.dart';

/// The deep trench seen behind a pannable content (a map, a base)
/// floating in it: the water and light rays far away, sliding at
/// [farRate] of the content's drift, then the ridges of the trench walls,
/// nearer, at [midRate] (see [ParallaxLayer]).
///
/// Fills its box. Each layer is painted once for the box's size into a
/// bitmap, then only moved as [transform] pans the [content]: lay it
/// under the content's InteractiveViewer, sharing its controller. Never
/// takes a tap.
class TrenchBackdrop extends StatelessWidget {
  /// Share of the content's drift the far water follows.
  static const farRate = 0.15;

  /// Share of the content's drift the ridges follow.
  static const midRate = 0.35;

  /// Pixels per logical pixel of the far water's bitmap on a device of
  /// [devicePixelRatio]: half of them, as it is all soft gradients.
  static double waterResolution(double devicePixelRatio) =>
      math.max(1, devicePixelRatio / 2);

  final ValueListenable<Matrix4> transform;
  final Size content;

  const TrenchBackdrop({
    super.key,
    required this.transform,
    required this.content,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: Stack(fit: StackFit.expand, children: [
          ParallaxLayer(transform: transform, content: content,
              rate: farRate, tile: const TrenchWaterPainter(),
              resolution: waterResolution(
                  MediaQuery.maybeDevicePixelRatioOf(context) ?? 1)),
          ParallaxLayer(transform: transform, content: content,
              rate: midRate, tile: const TrenchRidgesPainter()),
        ]),
      );
}
