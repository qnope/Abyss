import 'dart:math';

import '../action/action_executor.dart';
import '../action/action_result.dart';
import '../action/end_turn_action.dart';
import '../action/end_turn_action_result.dart';
import '../game/cheat_codes.dart';
import '../game/difficulty.dart';
import '../game/game.dart';
import '../game/game_factory.dart';
import '../game/game_status.dart';
import 'game_script.dart';
import 'script_log_entry.dart';
import 'script_milestones.dart';
import 'script_run_report.dart';
import 'script_turn.dart';

/// Plays a whole game headless with a [GameScript].
///
/// One seed drives the map, every fight and every raid, so the same
/// script and seed always replay the same game.
class ScriptRunner {
  /// The game stops after this many turns if it is not over before; a
  /// replay stops on its own last turn instead.
  final int maxTurns;

  /// Difficulty of the games, unless the script pins its own.
  final Difficulty difficulty;

  final ActionExecutor _executor;

  ScriptRunner({
    this.maxTurns = 60,
    this.difficulty = Difficulty.normal,
    ActionExecutor? executor,
  })
      : _executor = executor ?? ActionExecutor();

  ScriptRunReport run(GameScript script, {required int seed}) {
    final Random random = Random(seed);
    final int drawnSeed = random.nextInt(0x7FFFFFFF);
    final Game game = GameFactory.newSinglePlayer(
      playerName: script.playerName,
      mapSeed: script.mapSeed ?? drawnSeed,
      difficulty: script.difficulty ?? difficulty,
    );
    CheatCodes.apply(game.humanPlayer);
    final List<ScriptLogEntry> log = <ScriptLogEntry>[];
    final ScriptMilestones milestones = ScriptMilestones();
    final int turnLimit = script.lastTurn ?? maxTurns;
    while (game.status == GameStatus.playing && game.turn <= turnLimit) {
      final ScriptTurn turn = ScriptTurn(
        game: game,
        random: random,
        log: log,
        executor: _executor,
      );
      script.playTurn(turn);
      milestones.observe(game, game.turn);
      if (turn.isOver || game.turn == script.lastTurn) break;
      final ActionResult end = _executor.execute(
          EndTurnAction(random: script.endTurnRandom(game.turn) ?? random),
          game,
          game.humanPlayer);
      final raid = end is EndTurnActionResult ? end.turnResult?.raid : null;
      if (raid != null) milestones.raids.add(ScriptRaid.of(raid));
    }
    return ScriptRunReport.of(
      game,
      scriptName: script.name,
      seed: seed,
      log: log,
      milestones: milestones,
    );
  }
}
