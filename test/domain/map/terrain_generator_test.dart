import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_generator.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;

  List<TerrainType> terrains(int seed) {
    final cells = TerrainGenerator.generate(
      width: width,
      height: height,
      random: Random(seed),
      baseX: baseX,
      baseY: baseY,
    );
    return cells.map((c) => c.terrain).toList();
  }

  group('TerrainGenerator', () {
    test('all cells are plain', () {
      final t = terrains(42);
      for (final terrain in t) {
        expect(terrain, TerrainType.plain);
      }
    });

    test('generates correct number of cells', () {
      final t = terrains(42);
      expect(t.length, width * height);
    });
  });
}
