import '../game/game.dart';
import '../game/player.dart';
import 'objective_progress.dart';

/// A condition on the state of a game that an objective asks a player to
/// reach. Pure: it reads the game, never changes it.
abstract class ObjectiveGoal {
  const ObjectiveGoal();

  ObjectiveProgress progressOf(Game game, Player player);
}

/// A goal met or not, in one step.
abstract class FlagGoal extends ObjectiveGoal {
  const FlagGoal();

  bool isMet(Game game, Player player);

  @override
  ObjectiveProgress progressOf(Game game, Player player) =>
      ObjectiveProgress.flag(isMet(game, player));
}
