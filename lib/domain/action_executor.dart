import 'action.dart';
import 'action_result.dart';
import 'game.dart';

class ActionExecutor {
  ActionResult execute(Action action, Game game) {
    final validation = action.validate(game);
    if (!validation.isSuccess) return validation;
    return action.execute(game);
  }
}
