import 'package:flutter/rendering.dart';

import 'map_cell_visual.dart';
import 'map_flat_contents.dart';

/// Indexes of the [visuals] (a map [columns] cells wide) the standing
/// layer draws, still or moving, seen through the fog or not, back to
/// front: a sprite overlaps the cells behind its own, never those ahead.
List<int> standingCells(List<MapCellVisual> visuals, int columns) {
  final cells = [
    for (var i = 0; i < visuals.length; i++)
      if (visuals[i].onStandingLayer) i,
  ];
  (int, int) rankOf(int i) => standingRankOf((i % columns, i ~/ columns),
      span: visuals[i].contentSpan);
  final ranks = {for (final i in cells) i: rankOf(i)};
  cells.sort((a, b) => compareStandingRanks(ranks[a]!, ranks[b]!));
  return cells;
}

/// The drawing rank of a content standing on [cell], or on the [span] by
/// [span] block from it: the depth of its centre (x + y) first, then
/// from left to right (twice x, so a block's centre falls between).
(int, int) standingRankOf((int, int) cell, {int span = 1}) {
  final (x, y) = cell;
  return (x + y + span - 1, 2 * x + span - 1);
}

/// Orders ranks of [standingRankOf] from back to front.
int compareStandingRanks((int, int) a, (int, int) b) =>
    a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2);

/// The part of the map shown in a [viewport] when the map is drawn
/// through [transform] (as an InteractiveViewer moves its child).
Rect visibleMapRect(Matrix4 transform, Size viewport) =>
    MatrixUtils.inverseTransformRect(transform, Offset.zero & viewport);
