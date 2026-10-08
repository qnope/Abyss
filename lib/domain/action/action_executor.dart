import 'action.dart';
import 'action_result.dart';
import '../game/game.dart';
import '../game/player.dart';

class ActionExecutor {
  ActionResult execute(Action action, Game game, Player player) {
    final validation = action.validate(game, player);
    if (!validation.isSuccess) return validation;
    final turn = game.turn;
    final result = action.execute(game, player);
    if (result.isSuccess) {
      if (player.id == game.humanPlayerId) game.replay?.record(turn, action);
      final entry = action.makeHistoryEntry(game, player, result, game.turn);
      if (entry != null) player.addHistoryEntry(entry);
      player.raidState.addNoise(action.noiseMade(player));
    }
    return result;
  }
}
