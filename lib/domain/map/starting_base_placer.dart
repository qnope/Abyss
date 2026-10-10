import 'dart:math';
import 'grid_position.dart';

/// Picks the starting bases of the other players, far from each other.
class StartingBasePlacer {
  static const _margin = 2;

  /// [first] and then [count] - 1 more bases on a [size] map: each one
  /// is drawn among the cells farthest from the bases already placed.
  /// The centre, where the Noyau stands, is never taken.
  static List<GridPosition> place({
    required int size,
    required GridPosition first,
    required int count,
    required Random random,
  }) {
    final bases = [first];
    final centre = size ~/ 2;
    while (bases.length < count) {
      final scored = <GridPosition, int>{};
      for (var y = _margin; y < size - _margin; y++) {
        for (var x = _margin; x < size - _margin; x++) {
          if (x == centre && y == centre) continue;
          final cell = GridPosition(x: x, y: y);
          scored[cell] = bases.map((b) => _distance(cell, b)).reduce(min);
        }
      }
      final best = scored.values.reduce(max);
      final pool = [
        for (final e in scored.entries)
          if (e.value >= best - 1) e.key,
      ];
      bases.add(pool[random.nextInt(pool.length)]);
    }
    return bases;
  }

  static int _distance(GridPosition a, GridPosition b) =>
      max((a.x - b.x).abs(), (a.y - b.y).abs());
}
