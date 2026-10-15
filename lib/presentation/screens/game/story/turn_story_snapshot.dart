import '../../../../domain/game/player.dart';
import '../../../../domain/map/grid_position.dart';

/// What the story of a turn needs to know of the player before the turn
/// ends: the cells seen on each level, and where scouts wait.
class TurnStorySnapshot {
  /// Cells seen on each level.
  final Map<int, Set<GridPosition>> revealed;

  /// Cells scouts were sent to, as (level, x, y).
  final Set<(int, int, int)> scouts;

  const TurnStorySnapshot({required this.revealed, required this.scouts});

  /// What [player] has seen and sent exploring now.
  TurnStorySnapshot.of(Player player)
      : revealed = {
          for (final MapEntry(:key, :value)
              in player.revealedCellsPerLevel.entries)
            key: {...value},
        },
        scouts = {
          for (final order in player.pendingExplorations)
            (order.level, order.target.x, order.target.y),
        };

  /// Cells [player] has seen on [level] since this snapshot.
  Set<(int, int)> newlySeen(Player player, int level) {
    final before = revealed[level] ?? const {};
    return {
      for (final cell in player.revealedCellsOnLevel(level))
        if (!before.contains(cell)) (cell.x, cell.y),
    };
  }

  /// Cells of [level] where a scout waited and waits no more for [player].
  Set<(int, int)> scoutsGone(Player player, int level) {
    final still = TurnStorySnapshot.of(player).scouts;
    return {
      for (final scout in scouts)
        if (scout.$1 == level && !still.contains(scout)) (scout.$2, scout.$3),
    };
  }
}
