import 'package:flutter/rendering.dart';

import '../ambience/ambient_motion.dart';
import 'map_cell_visual.dart';

/// Indexes of the [visuals] whose content moves, in drawing order: cells
/// of one cell first, then wide contents over the terrain they cover,
/// then contents seen through the fog, as the static map orders them.
List<int> animatedCells(List<MapCellVisual> visuals) {
  final cells = <int>[], wide = <int>[], beacons = <int>[];
  for (var i = 0; i < visuals.length; i++) {
    final visual = visuals[i];
    if (visual.motion == AmbientMotion.still) continue;
    if (visual.aboveFog) {
      beacons.add(i);
    } else if (visual.contentSpan > 1) {
      wide.add(i);
    } else {
      cells.add(i);
    }
  }
  return [...cells, ...wide, ...beacons];
}

/// The part of the map shown in a [viewport] when the map is drawn
/// through [transform] (as an InteractiveViewer moves its child).
Rect visibleMapRect(Matrix4 transform, Size viewport) =>
    MatrixUtils.inverseTransformRect(transform, Offset.zero & viewport);
