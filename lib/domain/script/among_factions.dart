import 'dart:math';

import '../faction/faction_catalogue.dart';
import '../faction/faction_personality.dart';
import '../game/difficulty.dart';
import 'game_script.dart';
import 'script_turn.dart';

/// A script played in a world with factions: the same moves as [inner],
/// with [factions] racing it to the volcano.
class AmongFactions extends GameScript {
  final GameScript inner;

  @override
  final List<FactionPersonality> factions;

  const AmongFactions(this.inner, this.factions);

  /// [count] factions drawn from the catalogue with [seed].
  factory AmongFactions.drawn(GameScript inner, int count, {int seed = 0}) =>
      AmongFactions(
        inner,
        count == 0
            ? const <FactionPersonality>[]
            : FactionCatalogue.draw(count, seed: seed),
      );

  @override
  String get name => '${inner.name}+${factions.length}';

  @override
  void playTurn(ScriptTurn turn) => inner.playTurn(turn);

  @override
  String get playerName => inner.playerName;

  @override
  int? get mapSeed => inner.mapSeed;

  @override
  Difficulty? get difficulty => inner.difficulty;

  @override
  bool get factionsPlay => inner.factionsPlay;

  @override
  int? get lastTurn => inner.lastTurn;

  @override
  Random? endTurnRandom(int turn) => inner.endTurnRandom(turn);
}
