import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/grid_position.dart';
import '../../map/reveal_area_calculator.dart';
import '../objective_goal.dart';

/// At least one exploration resolved on level 1: a revealed cell lies
/// outside the area revealed around the base when the game started.
///
/// Read from the revealed cells rather than the history, which forgets its
/// oldest entries.
class ExploredAroundBaseGoal extends FlagGoal {
  const ExploredAroundBaseGoal();

  @override
  bool isMet(Game game, Player player) {
    final map = game.mapForLevel(1);
    if (map == null) return false;
    final Set<GridPosition> start =
        RevealAreaCalculator.cellsToReveal(
          targetX: player.baseX,
          targetY: player.baseY,
          side: Player.initialRevealSide,
          mapWidth: map.width,
          mapHeight: map.height,
        ).toSet();
    return player.revealedCellsOnLevel(1).any((cell) => !start.contains(cell));
  }
}
