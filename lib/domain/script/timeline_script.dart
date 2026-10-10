import 'dart:math';

import '../game/difficulty.dart';
import '../game/player.dart';
import '../replay/seeded_random.dart';
import 'action_spec.dart';
import 'game_script.dart';
import 'script_turn.dart';

/// A scenario written in advance: the actions to play on given turns.
///
/// Turns the timeline leaves out are handed to [otherwise] when set, so a
/// scenario can force a few moves and let a strategy play the rest.
///
/// An exported replay also pins the map, the player, the dice of every end
/// of turn and the turn to stop on, so it plays the original game again.
/// An action may name another player: it is played as that player, in
/// order, and no strategy is ever asked for it.
class TimelineScript extends GameScript {
  @override
  final String name;

  final Map<int, List<ActionSpec>> turns;
  final GameScript? otherwise;

  final String? player;

  @override
  final int? mapSeed;

  @override
  final Difficulty? difficulty;

  @override
  final int? lastTurn;

  final Map<int, int> endTurnSeeds;

  /// Who plays each action of [turns], by turn and position; `null`, or
  /// no entry, is the player the script runs for.
  final Map<int, List<String?>> actors;

  const TimelineScript({
    required this.name,
    required this.turns,
    this.otherwise,
    this.player,
    this.mapSeed,
    this.difficulty,
    this.lastTurn,
    this.endTurnSeeds = const <int, int>{},
    this.actors = const <int, List<String?>>{},
  });

  @override
  String get playerName => player ?? name;

  @override
  Random? endTurnRandom(int turn) {
    final int? seed = endTurnSeeds[turn];
    return seed == null ? null : SeededRandom(seed);
  }

  @override
  void playTurn(ScriptTurn turn) {
    final List<ActionSpec>? planned = turns[turn.number];
    if (planned == null) {
      otherwise?.playTurn(turn);
      return;
    }
    for (var i = 0; i < planned.length; i++) {
      final String? id = i < (actors[turn.number]?.length ?? 0)
          ? actors[turn.number]![i]
          : null;
      _turnOf(turn, id).perform(planned[i](turn.random));
    }
  }

  ScriptTurn _turnOf(ScriptTurn turn, String? id) {
    if (id == null) return turn;
    final Player? other = turn.game.players[id];
    if (other == null) {
      throw StateError('Joueur inconnu dans le scénario : $id');
    }
    return turn.asPlayer(other);
  }
}
