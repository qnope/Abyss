import 'dart:math';

import '../action/action_executor.dart';
import '../faction/faction_personality.dart';
import '../faction/faction_turn.dart';
import '../game/difficulty.dart';
import '../replay/seeded_random.dart';
import '../script/game_script.dart';
import '../script/script_turn.dart';

/// Plays [inner] with dice the journal can write down: every action that
/// rolls dice gets a freshly seeded generator of its own, and so does
/// every end of turn, the way the game screen plays. The journal of the
/// game is then exact: replaying it plays the very same game.
///
/// The seeds come from one generator, `Random(seed)`, drawn in the order
/// the strategy asks for dice, then one per end of turn. A turn of the
/// human is played as a [FactionTurn], which is that very way of rolling.
class SeededScript extends GameScript {
  final GameScript inner;
  final ActionExecutor _executor;
  final Random _seeds;

  SeededScript(
    this.inner, {
    required int seed,
    required ActionExecutor executor,
  }) : _executor = executor,
       _seeds = Random(seed);

  @override
  String get name => inner.name;

  @override
  String get playerName => inner.playerName;

  @override
  int? get mapSeed => inner.mapSeed;

  @override
  Difficulty? get difficulty => inner.difficulty;

  @override
  List<FactionPersonality> get factions => inner.factions;

  @override
  bool get factionsPlay => inner.factionsPlay;

  @override
  int? get lastTurn => inner.lastTurn;

  @override
  void playTurn(ScriptTurn turn) => inner.playTurn(
    FactionTurn(
      game: turn.game,
      player: turn.player,
      executor: _executor,
      seeds: _seeds,
    ),
  );

  /// The seed a replay recorded for the end of [turn], or a fresh one.
  @override
  Random? endTurnRandom(int turn) =>
      inner.endTurnRandom(turn) ?? SeededRandom(_seeds.nextInt(0x7FFFFFFF));
}
