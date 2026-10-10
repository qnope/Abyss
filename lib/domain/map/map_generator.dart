import 'dart:math';
import 'cell_content_type.dart';
import 'content_placer.dart';
import 'game_map.dart';
import 'grid_position.dart';
import 'map_cell.dart';
import 'map_generation_result.dart';
import 'map_layout.dart';
import 'starting_base_placer.dart';
import 'terrain_generator.dart';
import 'transition_base_placer.dart';
import 'volcanic_kernel_placer.dart';

class MapGenerator {
  static const _offset = 2;

  static MapGenerationResult generate({
    int? seed,
    int level = 1,
    Map<GridPosition, String> reservedPassages = const {},
    int playerCount = 1,
  }) {
    final size = MapLayout.sizeFor(playerCount);
    final extraPosts = MapLayout.extraPostsFor(playerCount);
    final actualSeed = seed ?? Random().nextInt(0x7FFFFFFF);
    final random = Random(actualSeed);

    final center = size ~/ 2;
    final baseX = center + random.nextInt(_offset * 2 + 1) - _offset;
    final baseY = center + random.nextInt(_offset * 2 + 1) - _offset;
    final bases = level == 1
        ? StartingBasePlacer.place(
            size: size,
            first: GridPosition(x: baseX, y: baseY),
            count: playerCount,
            random: random,
          )
        : [GridPosition(x: baseX, y: baseY)];
    final otherBases = bases.skip(1).toList();

    final reservedIndices = {
      for (final pos in reservedPassages.keys) pos.y * size + pos.x,
    };
    final (minLairs, maxLairs) = MapLayout.lairRangeFor(size);

    final cells = TerrainGenerator.generate(
      width: size,
      height: size,
      random: random,
      baseX: baseX,
      baseY: baseY,
    );

    ContentPlacer.place(
      cells: cells,
      width: size,
      height: size,
      baseX: baseX,
      baseY: baseY,
      random: random,
      reservedIndices: reservedIndices,
      familySeed: actualSeed + level,
      otherBases: otherBases,
      minLairs: minLairs,
      maxLairs: maxLairs,
    );

    TransitionBasePlacer.place(
      cells: cells,
      width: size,
      height: size,
      baseX: baseX,
      baseY: baseY,
      level: level,
      random: random,
      reservedIndices: {
        ...reservedIndices,
        for (final b in otherBases) b.y * size + b.x,
      },
      extraPosts: extraPosts,
    );

    for (final b in bases) {
      _clearBaseContent(cells, size, b.x, b.y);
    }
    // Placed after the base is cleared, which may sit on the centre.
    if (level == 3) {
      VolcanicKernelPlacer.place(
        cells: cells,
        width: size,
        height: size,
      );
    }
    _markPassages(cells, size, baseX, baseY, reservedPassages);

    return MapGenerationResult(
      map: GameMap(
        width: size,
        height: size,
        cells: cells,
        seed: actualSeed,
      ),
      baseX: baseX,
      baseY: baseY,
      bases: bases,
    );
  }

  static void _clearBaseContent(
    List<MapCell> cells, int size, int baseX, int baseY,
  ) {
    final i = baseY * size + baseX;
    cells[i] = cells[i].copyWith(content: CellContentType.empty);
  }

  static void _markPassages(
    List<MapCell> cells, int size, int baseX, int baseY,
    Map<GridPosition, String> reservedPassages,
  ) {
    for (final entry in reservedPassages.entries) {
      final x = entry.key.x, y = entry.key.y;
      if (x == baseX && y == baseY) continue;
      final i = y * size + x;
      cells[i] = cells[i].copyWith(
        content: CellContentType.passage,
        passageName: entry.value,
      );
    }
  }
}
