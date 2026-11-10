import 'dart:math';

import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';
import 'package:abyss/domain/map/starting_base_placer.dart';
import 'package:abyss/domain/map/volcanic_kernel_placer.dart';

import '../vector_file.dart';

/// Where things stand on a map: the starting bases, the cells a base or
/// a scout reveals, the cells of the volcano.
abstract final class MapPlacementSections {
  static final Map<String, VectorSection> sections = {
    'startingBases': VectorSection(
      'StartingBasePlacer.place(size: size, first: GridPosition(x: '
          'first[0], y: first[1]), count: count, random: Random(seed)) '
          'as [x, y]',
      () => [
        for (final (int size, int count) in const [
          (20, 1), (20, 2), (20, 3), (26, 4), (26, 6), (32, 7), (32, 11),
        ])
          for (final int seed in const [0, 1, 42])
            for (final (int x, int y) in [(size ~/ 2 - 2, size ~/ 2 + 1), (8, 8)])
              {
                'size': size,
                'count': count,
                'seed': seed,
                'first': [x, y],
                'out': [
                  for (final GridPosition p in StartingBasePlacer.place(
                    size: size,
                    first: GridPosition(x: x, y: y),
                    count: count,
                    random: Random(seed),
                  ))
                    [p.x, p.y],
                ],
              },
      ],
    ),
    'reveal': VectorSection(
      'RevealAreaCalculator.cellsToReveal(targetX: x, targetY: y, side: '
          'side, mapWidth: 20, mapHeight: 20) as [x, y]; side 5 is '
          'aroundBase',
      () => [
        for (final (int x, int y) in const [(10, 10), (0, 0), (19, 18), (1, 5)])
          for (final int side in const [1, 3, 5, 7, 9, 11])
            {
              'x': x,
              'y': y,
              'side': side,
              'out': [
                for (final GridPosition p in RevealAreaCalculator.cellsToReveal(
                  targetX: x,
                  targetY: y,
                  side: side,
                  mapWidth: 20,
                  mapHeight: 20,
                ))
                  [p.x, p.y],
              ],
            },
      ],
    ),
    'volcano': VectorSection(
      'VolcanicKernelPlacer.footprint(x, y) as [x, y], the anchor first',
      () => [
        for (final (int x, int y) in const [(10, 10), (13, 13), (16, 16)])
          {
            'x': x,
            'y': y,
            'out': [
              for (final (int fx, int fy) in VolcanicKernelPlacer.footprint(x, y))
                [fx, fy],
            ],
          },
      ],
    ),
  };
}
