import '../map/map_generator.dart';
import 'game.dart';
import 'player.dart';

/// Builds a fresh single-player game: a generated first level and a
/// player standing on its base.
abstract final class GameFactory {
  /// [mapSeed] makes the first level reproducible; `null` draws one.
  static Game newSinglePlayer({required String playerName, int? mapSeed}) {
    final generation = MapGenerator.generate(seed: mapSeed);
    final player = Player.withBase(
      name: playerName,
      baseX: generation.baseX,
      baseY: generation.baseY,
      mapWidth: generation.map.width,
      mapHeight: generation.map.height,
    );
    return Game.singlePlayer(player)..levels = {1: generation.map};
  }
}
