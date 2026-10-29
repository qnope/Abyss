import 'dart:ui';

import '../common/back_to_front.dart' as order;
import 'army_layout.dart';

/// Where the figures of a squad stand on their drill pad, in cells from the
/// pad centre (dx along u, dy along v).
abstract final class SquadSlots {
  /// One slot per figure, in the order the figures arrive as the squad
  /// grows: the first stands just in front of the centre.
  static const arrival = [
    Offset(.3, .3),
    Offset(-.42, .62),
    Offset(.62, -.42),
    Offset(-.55, -.05),
    Offset(-.05, -.55),
    Offset(-1.05, .45),
  ];

  /// The slots of the first [count] figures, from the back to the front.
  static List<Offset> backToFront(int count) =>
      order.backToFront(arrival.take(count), ArmyLayout.depthOf);
}
