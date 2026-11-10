import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/world_generator.dart';

import '../vector_file.dart';
import 'map_writer.dart';

/// Whole generated maps, cell by cell, for a spread of seeds, the three
/// levels and the map sizes of 1 to 11 players.
abstract final class MapVectors {
  /// Seed and number of players of each world: mostly the solo game,
  /// then every map size and number of extra posts.
  static const List<(int, int)> worlds = <(int, int)>[
    (0, 1), (1, 1), (2, 1), (3, 1), (42, 1), (1000, 1), (123456789, 1),
    (2147483646, 1), (7, 2), (7, 3), (5, 4), (6, 6), (9, 7), (11, 11),
  ];

  /// Passages a level is asked to keep, as the bases of the level above
  /// would: on free cells, on the starting base, on the volcano.
  static final Map<GridPosition, String> _passages = <GridPosition, String>{
    GridPosition(x: 0, y: 0): 'faille:0',
    GridPosition(x: 19, y: 3): 'faille:1',
    GridPosition(x: 10, y: 10): 'faille:2',
    GridPosition(x: 11, y: 11): 'faille:3',
    GridPosition(x: 9, y: 10): 'faille:4',
    GridPosition(x: 8, y: 12): 'faille:5',
  };

  static const String _map =
      'a map is its seed, width, height, baseX, baseY, bases as [x, y], '
      'and cells: [index, content, lair, transitionBase, passageName] '
      'for each cell holding anything, index = y * width + x, lair as '
      '[difficulty, family, unitCount], transitionBase as [type, name], '
      'the trailing nulls left out (see the README)';

  static final VectorFile file = VectorFile('maps', {
    'world': VectorSection(
      'WorldGenerator.generate(seed: seed, playerCount: players): the '
          'MapGenerationResult of levels 1, 2 and 3; $_map',
      () => [
        for (final (int seed, int players) in worlds)
          {
            'seed': seed,
            'players': players,
            'out': {
              for (final e in WorldGenerator.generate(
                seed: seed,
                playerCount: players,
              ).entries)
                e.key: MapWriter.write(e.value),
            },
          },
      ],
    ),
    'level': VectorSection(
      'MapGenerator.generate(seed: seed, level: level, playerCount: '
          'players, reservedPassages: passages), passages given as '
          '[x, y, name] in order; $_map',
      () => [
        for (final int seed in const [4, 6, 20, 21, 99])
          for (final int level in const [1, 2, 3])
            for (final bool reserved in const [false, true])
              for (final int players in [1, if (level == 1 && seed == 4) 5])
                {
                  'seed': seed,
                  'level': level,
                  'players': players,
                  'passages': [
                    if (reserved)
                      for (final e in _passages.entries)
                        [e.key.x, e.key.y, e.value],
                  ],
                  'out': MapWriter.write(
                    MapGenerator.generate(
                      seed: seed,
                      level: level,
                      playerCount: players,
                      reservedPassages: reserved ? _passages : const {},
                    ),
                  ),
                },
      ],
    ),
  });
}
