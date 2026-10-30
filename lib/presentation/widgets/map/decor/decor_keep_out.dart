import 'dart:ui';

import 'map_decor.dart';

/// Something on the map that decor keeps out of the way of, in
/// projection coordinates.
///
/// No decor reaches into its [core] (where it is tapped, what of it must
/// stay in sight). A decor standing in front of it (its foot lower than
/// [depth]) does not reach into anything it [drawn] either: drawn under
/// it in a still layer, such a decor would wrongly show behind it. A
/// decor behind it may hide behind its edges, as it would in the sea.
class DecorKeepOut {
  final Rect core;
  final Rect drawn;

  /// The height of its foot on screen: what stands lower is in front.
  final double depth;

  const DecorKeepOut({
    required this.core,
    required this.drawn,
    required this.depth,
  });

  /// A [box] lying on the floor, kept clear by every decor.
  const DecorKeepOut.box(Rect box)
      : core = box,
        drawn = box,
        depth = double.negativeInfinity;

  /// Whether [decor] would get in the way.
  bool blocks(MapDecor decor) {
    final body = decor.body;
    return body.overlaps(core) ||
        (decor.foot.dy > depth && body.overlaps(drawn));
  }
}
