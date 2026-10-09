import 'dart:math';

import '../map/map_generator.dart';
import 'difficulty.dart';
import 'game.dart';
import '../replay/replay_journal.dart';
import 'player.dart';

/// Builds a fresh single-player game: a generated first level and a
/// player standing on its base.
abstract final class GameFactory {
  /// [mapSeed] makes the first level reproducible; `null` draws one.
  static Game newSinglePlayer({
    required String playerName,
    int? mapSeed,
    Difficulty difficulty = Difficulty.normal,
  }) {
    final int seed = mapSeed ?? Random().nextInt(0x7FFFFFFF);
    final generation = MapGenerator.generate(seed: seed);
    final player = Player.withBase(
      name: playerName,
      baseX: generation.baseX,
      baseY: generation.baseY,
      mapWidth: generation.map.width,
      mapHeight: generation.map.height,
    );
    return Game.singlePlayer(player, difficulty: difficulty)
      ..levels = {1: generation.map}
      ..replay = ReplayJournal(mapSeed: seed, playerName: playerName);
  }
}
