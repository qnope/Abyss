import 'dart:math';
import 'cell_content_type.dart';
import 'content_placer.dart';
import 'game_map.dart';
import 'grid_position.dart';
import 'map_cell.dart';
import 'map_generation_result.dart';
import 'terrain_generator.dart';
import 'transition_base_placer.dart';
import 'volcanic_kernel_placer.dart';

class MapGenerator {
  static const _size = 20;
  static const _center = 10;
  static const _offset = 2;

  static MapGenerationResult generate({
    int? seed,
    int level = 1,
    Map<GridPosition, String> reservedPassages = const {},
  }) {
    final actualSeed = seed ?? Random().nextInt(0x7FFFFFFF);
    final random = Random(actualSeed);

    final baseX = _center + random.nextInt(_offset * 2 + 1) - _offset;
    final baseY = _center + random.nextInt(_offset * 2 + 1) - _offset;

    final reservedIndices = {
      for (final pos in reservedPassages.keys)
        pos.y * _size + pos.x,
    };

    final cells = TerrainGenerator.generate(
      width: _size,
      height: _size,
      random: random,
      baseX: baseX,
      baseY: baseY,
    );

    ContentPlacer.place(
      cells: cells,
      width: _size,
      height: _size,
      baseX: baseX,
      baseY: baseY,
      random: random,
      reservedIndices: reservedIndices,
    );

    TransitionBasePlacer.place(
      cells: cells,
      width: _size,
      height: _size,
      baseX: baseX,
      baseY: baseY,
      level: level,
      random: random,
      reservedIndices: reservedIndices,
    );

    if (level == 3) {
      VolcanicKernelPlacer.place(
        cells: cells,
        width: _size,
        height: _size,
      );
    }

    _clearBaseContent(cells, baseX, baseY);
    _markPassages(cells, baseX, baseY, reservedPassages);

    return MapGenerationResult(
      map: GameMap(
        width: _size,
        height: _size,
        cells: cells,
        seed: actualSeed,
      ),
      baseX: baseX,
      baseY: baseY,
    );
  }

  static void _clearBaseContent(
    List<MapCell> cells, int baseX, int baseY,
  ) {
    final i = baseY * _size + baseX;
    cells[i] = cells[i].copyWith(content: CellContentType.empty);
  }

  static void _markPassages(
    List<MapCell> cells, int baseX, int baseY,
    Map<GridPosition, String> reservedPassages,
  ) {
    for (final entry in reservedPassages.entries) {
      final x = entry.key.x, y = entry.key.y;
      if (x == baseX && y == baseY) continue;
      final i = y * _size + x;
      cells[i] = cells[i].copyWith(
        content: CellContentType.passage,
        passageName: entry.value,
      );
    }
  }
}
