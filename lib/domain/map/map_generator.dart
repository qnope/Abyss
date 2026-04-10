import 'dart:math';
import 'cell_content_type.dart';
import 'content_placer.dart';
import 'game_map.dart';
import 'map_generation_result.dart';
import 'terrain_generator.dart';
import 'transition_base_placer.dart';

class MapGenerator {
  static const _size = 20;
  static const _center = 10;
  static const _offset = 2;

  static MapGenerationResult generate({int? seed, int level = 1}) {
    final actualSeed = seed ?? Random().nextInt(0x7FFFFFFF);
    final random = Random(actualSeed);

    final baseX = _center + random.nextInt(_offset * 2 + 1) - _offset;
    final baseY = _center + random.nextInt(_offset * 2 + 1) - _offset;

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
    );

    TransitionBasePlacer.place(
      cells: cells,
      width: _size,
      height: _size,
      baseX: baseX,
      baseY: baseY,
      level: level,
      random: random,
    );

    _clearBaseContent(cells, baseX, baseY);

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
    List cells, int baseX, int baseY,
  ) {
    final i = baseY * _size + baseX;
    cells[i] = cells[i].copyWith(content: CellContentType.empty);
  }
}
