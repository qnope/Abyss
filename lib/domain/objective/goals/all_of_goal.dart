import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';
import '../objective_progress.dart';

/// Every one of [goals]; their steps add up.
class AllOfGoal extends ObjectiveGoal {
  final List<ObjectiveGoal> goals;

  const AllOfGoal(this.goals);

  @override
  ObjectiveProgress progressOf(Game game, Player player) => goals
      .map((goal) => goal.progressOf(game, player))
      .reduce((a, b) => a + b);
}
