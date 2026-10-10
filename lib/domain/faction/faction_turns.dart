import 'dart:math';

import '../action/action_executor.dart';
import '../game/game.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import 'faction.dart';
import 'faction_brain.dart';
import 'faction_turn.dart';

/// Plays the turn of every faction, one after the other in the order of
/// [Game.factions], through the regular [ActionExecutor] so the actions
/// are journalled for the replay.
///
/// The end of the human's turn calls it before the resolution. A replay
/// does not: the journal already holds what the brains did.
abstract final class FactionTurns {
  static void playAll(Game game, {ActionExecutor? executor}) {
    final ActionExecutor run = executor ?? ActionExecutor();
    final int mapSeed = game.levels[1]?.seed ?? 0;
    final List<Faction> factions = game.factions;
    for (var i = 0; i < factions.length; i++) {
      if (game.status != GameStatus.playing) return;
      final Player? player = game.players[factions[i].id];
      if (player == null || player.hasFallen) continue;
      FactionBrain(factions[i].personality).playTurn(
        FactionTurn(
          game: game,
          player: player,
          executor: run,
          seeds: Random(_seedOf(mapSeed, game.turn, i)),
        ),
      );
    }
  }

  /// The dice of one faction on one turn; the same game always gives the
  /// same numbers, whatever the platform.
  static int _seedOf(int mapSeed, int turn, int index) =>
      (mapSeed * 31 + turn * 1009 + index * 7919) & 0x7FFFFFFF;
}
