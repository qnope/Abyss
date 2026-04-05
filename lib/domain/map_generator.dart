import 'dart:math';
import 'cell_content_type.dart';
import 'content_placer.dart';
import 'game_map.dart';
import 'terrain_generator.dart';

class MapGenerator {
  static const _size = 20;
  static const _center = 10;
  static const _offset = 2;
  static const _revealRadius = 2;

  static GameMap generate({int? seed}) {
    final actualSeed = seed ?? Random().nextInt(1 << 32);
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

    _applyFogOfWar(cells, baseX, baseY);
    _clearBaseContent(cells, baseX, baseY);

    return GameMap(
      width: _size,
      height: _size,
      cells: cells,
      playerBaseX: baseX,
      playerBaseY: baseY,
      seed: actualSeed,
    );
  }

  static void _applyFogOfWar(
    List cells, int baseX, int baseY,
  ) {
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final dist = max((x - baseX).abs(), (y - baseY).abs());
        if (dist <= _revealRadius) {
          final i = y * _size + x;
          cells[i] = cells[i].copyWith(isRevealed: true);
        }
      }
    }
  }

  static void _clearBaseContent(
    List cells, int baseX, int baseY,
  ) {
    final i = baseY * _size + baseX;
    cells[i] = cells[i].copyWith(content: CellContentType.empty);
  }
}
