import 'dart:math';

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
class TimelineScript extends GameScript {
  @override
  final String name;

  final Map<int, List<ActionSpec>> turns;
  final GameScript? otherwise;

  final String? player;

  @override
  final int? mapSeed;

  @override
  final int? lastTurn;

  final Map<int, int> endTurnSeeds;

  const TimelineScript({
    required this.name,
    required this.turns,
    this.otherwise,
    this.player,
    this.mapSeed,
    this.lastTurn,
    this.endTurnSeeds = const <int, int>{},
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
    for (final ActionSpec spec in planned) {
      turn.perform(spec(turn.random));
    }
  }
}
