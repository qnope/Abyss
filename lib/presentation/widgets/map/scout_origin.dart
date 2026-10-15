import '../../../domain/map/grid_position.dart';
import '../../../domain/map/post_holder.dart';

/// The cell a scout sent to [target] sets off from.
///
/// On the first level, the player's [base]. Deeper, the units of a level
/// came down through the passages under the posts the player holds
/// ([passageHolders]), so the nearest of those; without one, the nearest
/// [revealed] cell; with nothing revealed, the [target] itself.
(int, int) scoutOrigin(
  (int, int) target, {
  (int, int)? base,
  Map<GridPosition, PostHolder> passageHolders = const {},
  Set<GridPosition> revealed = const {},
}) {
  if (base != null) return base;
  final held = [
    for (final MapEntry(:key, :value) in passageHolders.entries)
      if (value == PostHolder.human) key,
  ];
  final candidates = held.isNotEmpty
      ? held
      : revealed.where((p) => (p.x, p.y) != target);
  return _nearest(target, candidates) ?? target;
}

/// The cell of [cells] nearest to [target]; between cells as near, the
/// upper one, then the left one, so the answer never depends on order.
(int, int)? _nearest((int, int) target, Iterable<GridPosition> cells) {
  (int, int)? best;
  var bestDistance = 0;
  for (final cell in cells) {
    final dx = cell.x - target.$1, dy = cell.y - target.$2;
    final distance = dx * dx + dy * dy;
    if (best == null ||
        distance < bestDistance ||
        (distance == bestDistance && _before(cell, best))) {
      best = (cell.x, cell.y);
      bestDistance = distance;
    }
  }
  return best;
}

bool _before(GridPosition cell, (int, int) other) =>
    cell.y < other.$2 || (cell.y == other.$2 && cell.x < other.$1);
