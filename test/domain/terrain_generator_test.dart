import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/terrain_generator.dart';
import 'package:abyss/domain/terrain_type.dart';

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
    test('base cell is plain', () {
      final t = terrains(42);
      expect(t[baseY * width + baseX], TerrainType.plain);
    });

    test('neighbors of base are reef or plain', () {
      final t = terrains(42);
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          final idx = (baseY + dy) * width + (baseX + dx);
          expect(
            t[idx] == TerrainType.reef || t[idx] == TerrainType.plain,
            isTrue,
            reason: 'Neighbor ($dx,$dy) should be reef or plain',
          );
        }
      }
    });

    test('all 4 edges reachable from base via non-rock path', () {
      final cells = TerrainGenerator.generate(
        width: width,
        height: height,
        random: Random(42),
        baseX: baseX,
        baseY: baseY,
      );
      final visited = List.filled(width * height, false);
      final queue = [(baseX, baseY)];
      visited[baseY * width + baseX] = true;
      while (queue.isNotEmpty) {
        final (cx, cy) = queue.removeAt(0);
        for (final (dx, dy) in [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
          final nx = cx + dx, ny = cy + dy;
          if (nx < 0 || nx >= width || ny < 0 || ny >= height) continue;
          final idx = ny * width + nx;
          if (visited[idx]) continue;
          if (cells[idx].terrain == TerrainType.rock) continue;
          visited[idx] = true;
          queue.add((nx, ny));
        }
      }
      expect(
        List.generate(width, (x) => visited[x]), // top
        contains(true),
      );
      expect(
        List.generate(width, (x) => visited[(height - 1) * width + x]),
        contains(true),
      );
      expect(
        List.generate(height, (y) => visited[y * width]),
        contains(true),
      );
      expect(
        List.generate(height, (y) => visited[y * width + width - 1]),
        contains(true),
      );
    });

    test('same seed produces same terrain', () {
      expect(terrains(99), equals(terrains(99)));
    });

    test('different seeds produce different terrain', () {
      expect(terrains(1), isNot(equals(terrains(2))));
    });
  });
}
