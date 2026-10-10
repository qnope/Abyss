import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';

/// At least one research node done, in any branch.
class ResearchStartedGoal extends FlagGoal {
  const ResearchStartedGoal();

  @override
  bool isMet(Game game, Player player) =>
      player.techBranches.values.any((branch) => branch.researchLevel >= 1);
}
