import 'action.dart';
import 'action_result.dart';
import '../game/game.dart';
import '../game/player.dart';

class ActionExecutor {
  ActionResult execute(Action action, Game game, Player player) {
    final validation = action.validate(game, player);
    if (!validation.isSuccess) return validation;
    final result = action.execute(game, player);
    if (result.isSuccess) {
      final entry = action.makeHistoryEntry(game, player, result, game.turn);
      if (entry != null) player.addHistoryEntry(entry);
    }
    return result;
  }
}
