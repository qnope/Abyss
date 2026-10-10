import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/victory_checker.dart';
import 'package:abyss/domain/replay/seeded_random.dart';

/// The game of a human who does nothing against one faction of
/// [personality] left alone to run for the volcano, played until the
/// faction wins or [limit] turns.
///
/// The idle human would fall to the raids long before the faction could
/// finish, so a defeat that is not the faction's is taken back: only the
/// race is looked at.
Game playLoneFaction(
  FactionPersonality personality,
  int seed, {
  int limit = 220,
}) {
  final seeds = Random(seed);
  final game = GameFactory.newGame(
    playerName: 'Nemo',
    mapSeed: seeds.nextInt(0x7FFFFFFF),
    personalities: [personality],
  );
  final executor = ActionExecutor();
  while (game.turn < limit) {
    executor.execute(
      EndTurnAction(random: SeededRandom(seeds.nextInt(1 << 30))),
      game,
      game.humanPlayer,
    );
    if (VictoryChecker.winnerOf(game) != null) break;
    game.status = GameStatus.playing;
  }
  return game;
}
