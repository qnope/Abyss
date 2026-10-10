import 'dart:math';

import '../faction/faction.dart';
import '../faction/faction_catalogue.dart';
import '../faction/faction_personality.dart';
import '../map/map_generator.dart';
import '../map/map_generation_result.dart';
import '../map/world_generator.dart';
import '../objective/objective_state.dart';
import 'difficulty.dart';
import 'game.dart';
import '../replay/replay_journal.dart';
import 'player.dart';

/// Builds a fresh single-player game: a generated first level and a
/// player standing on its base.
abstract final class GameFactory {
  /// [mapSeed] makes the first level reproducible; `null` draws one.
  /// [tutorial] has the guide lead the player through the first chapter,
  /// with the tip cards.
  static Game newSinglePlayer({
    required String playerName,
    int? mapSeed,
    Difficulty difficulty = Difficulty.normal,
    bool tutorial = false,
  }) {
    final int seed = mapSeed ?? Random().nextInt(0x7FFFFFFF);
    final generation = MapGenerator.generate(seed: seed);
    final player = Player.withBase(
      name: playerName,
      baseX: generation.baseX,
      baseY: generation.baseY,
      mapWidth: generation.map.width,
      mapHeight: generation.map.height,
    )..savedObjectiveState = ObjectiveState(
      tutorialEnabled: tutorial,
      tipsEnabled: tutorial,
    );
    return Game.singlePlayer(player, difficulty: difficulty)
      ..levels = {1: generation.map}
      ..replay = ReplayJournal(mapSeed: seed, playerName: playerName);
  }

  /// A game against factions: [factionCount] (1 to 10) drawn from the
  /// catalogue with the map seed, or the given [personalities]. Each
  /// faction is a player on a base of its own, with a fog of its own, and
  /// the three levels are generated at once so that everybody descends in
  /// the same world. Without faction it is [newSinglePlayer].
  static Game newGame({
    required String playerName,
    int? mapSeed,
    Difficulty difficulty = Difficulty.normal,
    bool tutorial = false,
    int factionCount = 0,
    List<FactionPersonality>? personalities,
  }) {
    final int seed = mapSeed ?? Random().nextInt(0x7FFFFFFF);
    final List<FactionPersonality> drawn =
        personalities ??
        (factionCount == 0
            ? const <FactionPersonality>[]
            : FactionCatalogue.draw(factionCount, seed: seed));
    if (drawn.isEmpty && factionCount == 0) {
      return newSinglePlayer(
        playerName: playerName,
        mapSeed: seed,
        difficulty: difficulty,
        tutorial: tutorial,
      );
    }
    final world = WorldGenerator.generate(
      seed: seed,
      playerCount: drawn.length + 1,
    );
    final MapGenerationResult first = world[1]!;
    final Game game = Game.singlePlayer(
      _playerOn(first, 0, name: playerName)
        ..savedObjectiveState = ObjectiveState(
          tutorialEnabled: tutorial,
          tipsEnabled: tutorial,
        ),
      difficulty: difficulty,
    );
    for (var i = 0; i < drawn.length; i++) {
      final faction = Faction(drawn[i]);
      game.players[faction.id] = _playerOn(
        first,
        i + 1,
        name: faction.name,
        id: faction.id,
      );
    }
    return game
      ..levels = {for (final e in world.entries) e.key: e.value.map}
      ..savedFactions = drawn
      ..replay = ReplayJournal(mapSeed: seed, playerName: playerName);
  }

  static Player _playerOn(
    MapGenerationResult level, int base, {
    required String name,
    String? id,
  }) => Player.withBase(
    id: id,
    name: name,
    baseX: level.bases[base].x,
    baseY: level.bases[base].y,
    mapWidth: level.map.width,
    mapHeight: level.map.height,
  );
}
