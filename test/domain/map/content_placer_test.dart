import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/content_placer.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_generator.dart';

void main() {
  const width = 20, height = 20, baseX = 10, baseY = 10;

  List<MapCell> generate(int seed) {
    final random = Random(seed);
    final cells = TerrainGenerator.generate(
      width: width, height: height,
      random: random, baseX: baseX, baseY: baseY,
    );
    ContentPlacer.place(
      cells: cells, width: width, height: height,
      baseX: baseX, baseY: baseY, random: random,
    );
    return cells;
  }

  group('ContentPlacer', () {
    test('base zone cells have empty content', () {
      final cells = generate(42);
      for (var dy = -2; dy <= 2; dy++) {
        for (var dx = -2; dx <= 2; dx++) {
          final x = baseX + dx, y = baseY + dy;
          if (x < 0 || x >= width || y < 0 || y >= height) continue;
          expect(
            cells[y * width + x].content,
            CellContentType.empty,
            reason: 'Base zone cell ($x,$y) should be empty',
          );
        }
      }
    });

    test('monster lair count is between 5 and 10', () {
      for (var seed = 0; seed < 20; seed++) {
        final cells = generate(seed);
        final count = cells
            .where((c) => c.content == CellContentType.monsterLair)
            .length;
        expect(count, greaterThanOrEqualTo(5), reason: 'seed=$seed');
        expect(count, lessThanOrEqualTo(10), reason: 'seed=$seed');
      }
    });

    test('same seed produces same content', () {
      expect(
        generate(99).map((c) => c.content).toList(),
        equals(generate(99).map((c) => c.content).toList()),
      );
    });
  });
}
