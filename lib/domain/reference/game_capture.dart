import '../action/action.dart';
import '../action/action_executor.dart';
import '../action/action_result.dart';
import '../game/game.dart';
import '../game/player.dart';

/// An executor that keeps the game it plays, which `ScriptRunner` builds
/// and does not hand back.
class GameCapture extends ActionExecutor {
  Game? _game;

  /// The game played; throws while no action was executed.
  Game get game =>
      _game ?? (throw StateError('No action was executed: no game to read'));

  @override
  ActionResult execute(Action action, Game game, Player player) {
    if (_game == null) {
      _game = game;
      onStart(game);
    }
    return super.execute(action, game, player);
  }

  /// Called once, before the first action of the game.
  void onStart(Game game) {}
}
