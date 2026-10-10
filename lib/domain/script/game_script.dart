import 'dart:math';

import '../faction/faction_personality.dart';
import '../game/difficulty.dart';
import 'script_turn.dart';

/// A way to play a whole game without the UI.
///
/// Each turn, `ScriptRunner` hands the script a [ScriptTurn] to act on
/// through the regular action system, then ends the turn itself.
abstract class GameScript {
  const GameScript();

  /// Name shown in reports.
  String get name;

  /// Plays the current turn. Ending the turn is left to the runner.
  void playTurn(ScriptTurn turn);

  /// Name of the player; a replay keeps the one of the exported game.
  String get playerName => name;

  /// Seed of the first level; `null` lets the runner's seed pick it.
  int? get mapSeed => null;

  /// Difficulty the game was played in; `null` lets the runner pick it.
  Difficulty? get difficulty => null;

  /// Factions the game is played against, in the order they play; none by
  /// default, a replay names those of the exported game.
  List<FactionPersonality> get factions => const <FactionPersonality>[];

  /// Whether the factions' brains play at the end of each turn. A replay
  /// says no: the actions of the factions are already in its timeline.
  bool get factionsPlay => true;

  /// The turn the game stops on, before ending it; `null` plays on.
  int? get lastTurn => null;

  /// Generator for the end of [turn] (raids); `null` uses the runner's.
  Random? endTurnRandom(int turn) => null;
}
