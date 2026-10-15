import 'dart:math' as math;

import 'package:flutter/animation.dart';

import '../../../theme/abyss_motion.dart';
import '../map_content_drawer.dart';

/// Where a round token stands on the map: swimming from one cell to
/// another as its [progress] runs, or at rest in the corner of its
/// [target] once arrived.
///
/// A token swims in the middle of the cells, a little larger, and shrinks
/// into the bottom right corner of its target, leaving the cell's content
/// in sight while it waits there.
class MapTokenTrip {
  /// Side of a swimming token, as a share of a cell.
  static const swimScale = 0.6;

  /// Side of a token at rest, as a share of a cell.
  static const restScale = 0.45;

  /// Gap between a token at rest and the edges of its cell.
  static const restInset = 2.0;

  final (int, int) target;
  final (int, int)? origin;

  /// How far along the swim is, from 0 to 1; `null` once at rest.
  final Animation<double>? progress;

  /// A token already waiting on [target].
  const MapTokenTrip.atRest(this.target)
      : origin = null,
        progress = null;

  /// A token swimming [from] a cell [to] another as [progress] runs.
  const MapTokenTrip.swimming({
    required (int, int) from,
    required (int, int) to,
    required Animation<double> this.progress,
  })  : origin = from,
        target = to;

  /// Whether the token is still on its way.
  bool get isSwimming => progress != null;

  /// Where the token stands now.
  Rect get rect {
    final rest = restingRect(target);
    final progress = this.progress, origin = this.origin;
    if (progress == null || origin == null) return rest;
    final t = AbyssMotion.travel.transform(progress.value);
    return Rect.lerp(swimmingRect(origin), rest, t)!;
  }

  /// A token at rest in the bottom right corner of [cell].
  static Rect restingRect((int, int) cell) {
    const side = cellSize * restScale;
    final corner = _cell(cell).bottomRight - const Offset(restInset, restInset);
    return Rect.fromPoints(corner - const Offset(side, side), corner);
  }

  /// A token swimming through the middle of [cell].
  static Rect swimmingRect((int, int) cell) => Rect.fromCenter(
        center: _cell(cell).center,
        width: cellSize * swimScale,
        height: cellSize * swimScale,
      );

  /// How long a token takes to swim [from] a cell [to] another.
  static Duration durationOf((int, int) from, (int, int) to) {
    final dx = (to.$1 - from.$1).toDouble(), dy = (to.$2 - from.$2).toDouble();
    return AbyssMotion.swimOver(math.sqrt(dx * dx + dy * dy));
  }

  @override
  bool operator ==(Object other) =>
      other is MapTokenTrip &&
      other.target == target &&
      other.origin == origin &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(target, origin, progress);

  static Rect _cell((int, int) cell) => Rect.fromLTWH(
      cell.$1 * cellSize, cell.$2 * cellSize, cellSize, cellSize);
}
