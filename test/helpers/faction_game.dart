import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';

import '../domain/replay/two_player_replay_helper.dart';

/// [inner] played in a game against [factions].
class Factioned extends GameScript {
  final GameScript inner;

  @override
  final List<FactionPersonality> factions;

  Factioned(this.inner, this.factions);

  @override
  String get name => inner.name;

  @override
  void playTurn(ScriptTurn turn) => inner.playTurn(turn);
}

/// A game against [factions] factions where the human plays the balanced
/// strategy for [turns] turns, with journalled (seeded) dice, the way the
/// game screen does; the factions play inside the end of each turn.
Game playFactionGame(
  int factions,
  int turns, {
  int seed = 4,
  Difficulty difficulty = Difficulty.normal,
}) {
  final seeds = Random(seed);
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: seeds.nextInt(0x7FFFFFFF),
    difficulty: difficulty,
    factionCount: factions,
  );
  final executor = ActionExecutor();
  while (game.status == GameStatus.playing && game.turn < turns) {
    const BalancedStrategy().playTurn(LiveTurn(game, game.humanPlayer, seeds));
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      game,
      game.humanPlayer,
    );
  }
  return game;
}

/// Buildings levels and units of [player], to tell how far it has grown.
int growthOf(Player player) =>
    player.buildings.values.fold(0, (sum, b) => sum + b.level) +
    player.unitsPerLevel.values
        .expand((units) => units.values)
        .fold(0, (sum, u) => sum + u.count);

/// A game against [factions] factions where the human does nothing but end
/// its turns, so the factions find an easy prey; played until [turns] or
/// the end of the game.
Game playIdleFactionGame(int factions, int turns, {int seed = 1}) {
  final seeds = Random(seed);
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: seeds.nextInt(0x7FFFFFFF),
    factionCount: factions,
  );
  final executor = ActionExecutor();
  while (game.status == GameStatus.playing && game.turn < turns) {
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      game,
      game.humanPlayer,
    );
  }
  return game;
}
