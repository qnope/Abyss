import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/transition_base_type.dart';
import '../objective_goal.dart';

/// The transition base of [type] captured by the player.
class TransitionBaseCapturedGoal extends FlagGoal {
  final TransitionBaseType type;

  const TransitionBaseCapturedGoal(this.type);

  @override
  bool isMet(Game game, Player player) =>
      game.capturedBaseTypesOf(player.id).contains(type);
}
