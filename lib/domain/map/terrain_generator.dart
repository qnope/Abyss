import 'dart:math';
import 'map_cell.dart';
import 'terrain_type.dart';

class TerrainGenerator {
  static List<MapCell> generate({
    required int width,
    required int height,
    required Random random,
    required int baseX,
    required int baseY,
  }) {
    return List.generate(
      width * height,
      (_) => MapCell(terrain: TerrainType.plain),
    );
  }
}
