import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_goal.dart';

/// The volcanic kernel taken by the player, which opens its building.
class KernelCapturedGoal extends FlagGoal {
  const KernelCapturedGoal();

  @override
  bool isMet(Game game, Player player) =>
      game.isVolcanicKernelCapturedBy(player.id);
}
