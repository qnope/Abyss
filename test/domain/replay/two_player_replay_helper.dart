import 'dart:convert';
import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/strategies/economy_strategy.dart';

import '../../helpers/two_player_game.dart';
import 'live_game_helper.dart';

const String rivalId = 'rival-1';

class LiveTurn extends ScriptTurn {
  final Random _seeds;

  LiveTurn(Game game, Player player, this._seeds)
    : super(
        game: game,
        player: player,
        random: _seeds,
        log: <ScriptLogEntry>[],
      );

  @override
  Random get random => SeededRandom(_seeds.nextInt(0x7FFFFFFF));
}

/// A game where the human and the rival play [turns] turns, one after the
/// other, each with its own strategy and unpredictable seeds.
Game playTwo(int turns) {
  final two = TwoPlayerGame.create(rivalId: rivalId);
  final seeds = Random(5);
  final executor = ActionExecutor();
  const human = BalancedStrategy();
  const rival = EconomyStrategy();
  for (var t = 1; t <= turns; t++) {
    human.playTurn(LiveTurn(two.game, two.human, seeds));
    rival.playTurn(LiveTurn(two.game, two.rival, seeds));
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      two.game,
      two.human,
    );
  }
  return two.game;
}

/// Replays [source] on a fresh two-player game; returns it.
Game replayOn(Map<String, Object?> source) {
  final fresh = TwoPlayerGame.create(rivalId: rivalId);
  final script = ScenarioParser.parse(jsonEncode(source));
  ScriptRunner(
    maxTurns: 500,
  ).runOn(fresh.game, script, random: Random(1), seed: 1);
  return fresh.game;
}

Map<String, Object?> both(Game g) => <String, Object?>{
  'human': snapshotOf(g),
  'rival': snapshotOf(g, of: g.players[rivalId]),
};

/// The replay script, with [spy] as fallback for turns it leaves out.
class Fallback extends GameScript {
  final GameScript inner;
  final GameScript spy;

  Fallback(this.inner, this.spy);

  @override
  String get name => inner.name;

  @override
  int? get lastTurn => inner.lastTurn;

  @override
  Random? endTurnRandom(int turn) => inner.endTurnRandom(turn);

  @override
  void playTurn(ScriptTurn turn) {
    inner.playTurn(turn);
    spy.playTurn(turn);
  }
}
