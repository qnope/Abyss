import 'action.dart';
import 'action_result.dart';
import '../game/game.dart';
import '../game/player.dart';

class ActionExecutor {
  ActionResult execute(Action action, Game game, Player player) {
    final validation = action.validate(game, player);
    if (!validation.isSuccess) return validation;
    return action.execute(game, player);
  }
}
