import 'package:abyss/domain/leviathan/leviathan_resolver.dart';
import 'package:abyss/domain/leviathan/leviathan_return.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/replay/seeded_random.dart';

import '../../helpers/post_attack_helper.dart';

/// A game against two factions where the human holds a Faille with its
/// Module de descente at level 2, at turn 12, and the guardians'
/// counter-attack scheduled by its capture this very turn.
PostWar leviathanScene({int mapSeed = 7}) {
  final war = PostWar(
    TransitionBaseType.faille,
    mapSeed: mapSeed,
    humanHolds: true,
  );
  LeviathanResolver.onCapture(
    war.game,
    war.human,
    base: war.post,
    level: war.level,
    at: war.at,
  );
  return war;
}

extension LeviathanSceneTurns on PostWar {
  LeviathanReturn get leviathan => game.leviathanReturn!;

  /// The turn at the end of which the guardians strike.
  int get strikeTurn => leviathan.dueTurn!;

  /// Ends turns (the leviathan step only) until [turn] is the current one.
  void playUntil(int turn, {int seed = 3}) {
    while (game.turn < turn) {
      endTurn(seed: seed);
    }
  }

  /// Runs the leviathan step of the end of the current turn.
  LeviathanTurnOutcome endTurn({int seed = 3}) {
    final outcome = LeviathanResolver.resolve(game, random: SeededRandom(seed));
    game.turn++;
    return outcome;
  }
}
