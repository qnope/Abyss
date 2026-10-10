import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';
import '../objective_progress.dart';

/// [count] raids pushed back since the start of the game.
class RaidsRepelledGoal extends ObjectiveGoal {
  final int count;

  const RaidsRepelledGoal(this.count);

  @override
  ObjectiveProgress progressOf(Game game, Player player) =>
      ObjectiveProgress(player.raidState.raidsRepelled, count);
}
