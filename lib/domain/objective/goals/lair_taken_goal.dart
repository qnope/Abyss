import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/cell_content_type.dart';
import '../objective_goal.dart';

/// At least one monster lair beaten by the player, on any level: a won
/// fight marks the lair's cell as collected by the winner.
class LairTakenGoal extends FlagGoal {
  const LairTakenGoal();

  @override
  bool isMet(Game game, Player player) => game.levels.values.any(
    (map) => map.cells.any(
      (cell) =>
          cell.content == CellContentType.monsterLair &&
          cell.collectedBy == player.id,
    ),
  );
}
