import 'dart:math';

import 'package:abyss/domain/map/lair_builder.dart';
import 'package:abyss/domain/map/map_layout.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_name.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

import '../vector_file.dart';
import 'map_placement_vectors.dart';

/// The small rules a map is generated and explored with.
abstract final class MapRuleVectors {
  static const List<int> seeds = <int>[0, 1, 42, 1000, 2147483646];

  static final VectorFile file = VectorFile('map_rules', {
    'layout': VectorSection(
      'MapLayout.sizeFor(players), extraPostsFor(players) and '
          'lairRangeFor(size) as [min, max] for that size',
      () => [
        for (var players = 1; players <= MapLayout.maxPlayers; players++)
          {
            'players': players,
            'out': {
              'size': MapLayout.sizeFor(players),
              'extraPosts': MapLayout.extraPostsFor(players),
              'lairs': switch (MapLayout.lairRangeFor(
                MapLayout.sizeFor(players),
              )) {
                (final int min, final int max) => [min, max],
              },
            },
          },
      ],
    ),
    'lairFamily': VectorSection(
      'LairBuilder.familyFor(seed, cell, level) for each cell of cells',
      () => [
        for (final int seed in const [0, 1, 43, 1001, 2147483649, 271201])
          for (var level = 1; level <= 3; level++)
            {
              'seed': seed,
              'level': level,
              'cells': _cells,
              'out': [
                for (final int cell in _cells)
                  LairBuilder.familyFor(seed, cell, level),
              ],
            },
      ],
    ),
    'lair': VectorSection(
      'LairBuilder.build(difficulty: difficulty, random: Random(seed), '
          'familySeed: familySeed, cellIndex: cell) as [difficulty, '
          'family, unitCount, level, totalCount]',
      () => [
        for (final MonsterDifficulty d in MonsterDifficulty.values)
          for (final int seed in seeds)
            for (final (int familySeed, int cell) in const [(1, 0), (44, 399)])
              {
                'difficulty': d,
                'seed': seed,
                'familySeed': familySeed,
                'cell': cell,
                'out': _lair(
                  LairBuilder.build(
                    difficulty: d,
                    random: Random(seed),
                    familySeed: familySeed,
                    cellIndex: cell,
                  ),
                ),
              },
      ],
    ),
    'posts': VectorSection(
      'TransitionBaseName.allOf(type, extra: extra): their codes; and of '
          'TransitionBase(type: type, name: codes[0]): difficulty, '
          'pearlsPerTurn, targetLevel',
      () => [
        for (final TransitionBaseType type in TransitionBaseType.values)
          for (final int extra in const [0, 1, 5])
            {'type': type, 'extra': extra, 'out': _posts(type, extra)},
      ],
    ),
    ...MapPlacementSections.sections,
  });

  static const List<int> _cells = <int>[
    0, 1, 2, 3, 19, 20, 57, 123, 200, 399, 675, 1023,
  ];

  static List<Object?> _lair(MonsterLair lair) => [
    lair.difficulty, lair.family, lair.unitCount, lair.level, lair.totalCount,
  ];

  static Map<String, Object?> _posts(TransitionBaseType type, int extra) {
    final names = TransitionBaseName.allOf(type, extra: extra);
    final post = TransitionBase(type: type, name: names.first.code);
    return {
      'codes': [for (final n in names) n.code],
      'difficulty': post.difficulty,
      'pearlsPerTurn': post.pearlsPerTurn,
      'targetLevel': post.targetLevel,
    };
  }
}
