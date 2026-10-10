import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/replay/seeded_random.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_log_entry.dart';
import 'package:abyss/domain/script/script_turn.dart';

/// A turn played like in the game screen: every action that rolls dice
/// gets its own freshly seeded generator.
class _LiveTurn extends ScriptTurn {
  final Random _seeds;

  _LiveTurn({required super.game, required Random seeds})
    : _seeds = seeds,
      super(random: seeds, log: <ScriptLogEntry>[]);

  @override
  Random get random => SeededRandom(_seeds.nextInt(0x7FFFFFFF));
}

/// Plays [script] the way a player would in the app, with unpredictable
/// (but here reproducible) seeds, for [turns] turns or until it is over.
Game playLiveGame(GameScript script, {required int turns, int seed = 1}) {
  final Random seeds = Random(seed);
  final Game game = GameFactory.newSinglePlayer(
    playerName: 'Nemo',
    mapSeed: seeds.nextInt(0x7FFFFFFF),
  );
  final ActionExecutor executor = ActionExecutor();
  while (game.status == GameStatus.playing && game.turn <= turns) {
    final ScriptTurn turn = _LiveTurn(game: game, seeds: seeds);
    script.playTurn(turn);
    if (turn.isOver || game.turn == turns) break;
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      game,
      game.humanPlayer,
    );
  }
  return game;
}

/// Captures the game a `ScriptRunner` plays.
class SpyExecutor extends ActionExecutor {
  Game? game;

  @override
  execute(action, Game game, player) {
    this.game = game;
    return super.execute(action, game, player);
  }
}

/// What a replay must reproduce of [game].
Map<String, Object?> snapshotOf(Game game, {Player? of}) {
  final player = of ?? game.humanPlayer;
  return <String, Object?>{
    'turn': game.turn,
    'status': game.status.name,
    'levels': game.levels.keys.toList(),
    'resources': {
      for (final r in player.resources.entries) r.key.name: r.value.amount,
    },
    'buildings': {
      for (final b in player.buildings.entries) b.key.name: b.value.level,
    },
    'units': {
      for (final l in player.unitsPerLevel.entries)
        '${l.key}': {
          for (final u in l.value.entries) u.key.name: u.value.count,
        },
    },
    'noise': player.raidState.totalNoise,
    'attacks': [
      for (final a in player.raidState.attacks)
        '${a.attackerId} ${a.arrivalTurn} ${a.seed} ${a.units}',
    ],
    'history': [for (final e in player.historyEntries) '${e.turn} ${e.category.name}'],
  };
}
