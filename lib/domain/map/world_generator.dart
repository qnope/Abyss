import 'dart:math';
import 'map_generation_result.dart';
import 'map_generator.dart';
import 'passage_extractor.dart';

/// Generates every level of a map at once.
class WorldGenerator {
  static const levels = [1, 2, 3];

  /// The levels, each one holding the transition bases of the one above
  /// as passages, as the descent generates them one by one. Level 1 is
  /// what [MapGenerator.generate] gives for [seed]; the others get a seed
  /// drawn from it.
  static Map<int, MapGenerationResult> generate({
    int? seed,
    int playerCount = 1,
  }) {
    final actualSeed = seed ?? Random().nextInt(0x7FFFFFFF);
    final world = <int, MapGenerationResult>{};
    for (final level in levels) {
      world[level] = MapGenerator.generate(
        seed:
            level == 1
                ? actualSeed
                : Random(actualSeed + level).nextInt(0x7FFFFFFF),
        level: level,
        playerCount: playerCount,
        reservedPassages:
            level == 1
                ? const {}
                : PassageExtractor.from(world[level - 1]!.map),
      );
    }
    return world;
  }
}
