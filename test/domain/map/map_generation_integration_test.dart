import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('Map generation integration', () {
    test('seed reproducibility', () {
      final a = MapGenerator.generate(seed: 777);
      final b = MapGenerator.generate(seed: 777);
      expect(a.baseX, b.baseX);
      expect(a.baseY, b.baseY);
      for (var i = 0; i < 400; i++) {
        expect(a.map.cells[i].terrain, b.map.cells[i].terrain);
        expect(a.map.cells[i].content, b.map.cells[i].content);
        expect(
          a.map.cells[i].monsterDifficulty,
          b.map.cells[i].monsterDifficulty,
        );
      }
    });

    for (var seed = 0; seed < 10; seed++) {
      test('full constraints check (seed $seed)', () {
        final result = MapGenerator.generate(seed: seed);
        final map = result.map;

        expect(map.cells.length, 400);
        expect((result.baseX - 10).abs(), lessThanOrEqualTo(2));
        expect((result.baseY - 10).abs(), lessThanOrEqualTo(2));

        // All cells are plain
        for (final cell in map.cells) {
          expect(cell.terrain, TerrainType.plain);
        }

        // 5-10 monster lairs
        final lairs = map.cells
            .where((c) => c.content == CellContentType.monsterLair)
            .length;
        expect(lairs, greaterThanOrEqualTo(5));
        expect(lairs, lessThanOrEqualTo(10));

        // Base zone empty of content
        for (var dy = -2; dy <= 2; dy++) {
          for (var dx = -2; dx <= 2; dx++) {
            final x = result.baseX + dx;
            final y = result.baseY + dy;
            if (x < 0 || x >= 20 || y < 0 || y >= 20) continue;
            expect(map.cellAt(x, y).content, CellContentType.empty);
          }
        }
      });
    }
  });
}
