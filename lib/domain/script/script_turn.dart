import 'dart:math';

import '../action/action.dart';
import '../action/action_executor.dart';
import '../action/action_failure.dart';
import '../action/action_result.dart';
import '../game/game.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import '../game/victory_checker.dart';
import 'script_log_entry.dart';

/// What a [GameScript] sees and does during one turn.
///
/// Every action goes through [ActionExecutor], exactly like a tap in the
/// game screen, so a scripted game follows the same rules as a real one.
class ScriptTurn {
  final Game game;

  /// The game's seeded generator; give it to every action that rolls dice
  /// so that a seed always replays the same game.
  final Random random;

  final List<ScriptLogEntry> _log;
  final ActionExecutor _executor;

  ScriptTurn({
    required this.game,
    required this.random,
    required List<ScriptLogEntry> log,
    ActionExecutor? executor,
  })  : _log = log,
        _executor = executor ?? ActionExecutor();

  Player get player => game.humanPlayer;

  /// Number of the turn being played.
  int get number => game.turn;

  bool get isOver => game.status != GameStatus.playing;

  /// Whether [action] would succeed now, without performing or logging it.
  bool allows(Action action) =>
      !isOver && action.validate(game, player).isSuccess;

  /// Performs [action] and logs the outcome. A successful action may win
  /// the game, as it does in the game screen.
  ActionResult perform(Action action) {
    if (isOver) return const ActionResult.failure(ActionFailure.gameOver);
    final ActionResult result = _executor.execute(action, game, player);
    _log.add(ScriptLogEntry(
      turn: number,
      description: action.description,
      success: result.isSuccess,
      reason: result.reason,
    ));
    if (result.isSuccess) {
      game.status = VictoryChecker.check(game) ?? game.status;
    }
    return result;
  }

  /// Performs [action] only when it would succeed; returns whether it did.
  bool tryPerform(Action action) =>
      allows(action) && perform(action).isSuccess;
}
