import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('Map generation integration', () {
    test('seed reproducibility', () {
      final a = MapGenerator.generate(seed: 777);
      final b = MapGenerator.generate(seed: 777);
      expect(a.playerBaseX, b.playerBaseX);
      expect(a.playerBaseY, b.playerBaseY);
      for (var i = 0; i < 400; i++) {
        expect(a.cells[i].terrain, b.cells[i].terrain);
        expect(a.cells[i].content, b.cells[i].content);
        expect(a.cells[i].isRevealed, b.cells[i].isRevealed);
        expect(a.cells[i].monsterDifficulty, b.cells[i].monsterDifficulty);
      }
    });

    for (var seed = 0; seed < 10; seed++) {
      test('full constraints check (seed $seed)', () {
        final map = MapGenerator.generate(seed: seed);

        expect(map.cells.length, 400);
        expect((map.playerBaseX - 10).abs(), lessThanOrEqualTo(2));
        expect((map.playerBaseY - 10).abs(), lessThanOrEqualTo(2));

        // All cells are plain
        for (final cell in map.cells) {
          expect(cell.terrain, TerrainType.plain);
        }

        // 25 revealed cells
        final revealed = map.cells.where((c) => c.isRevealed).length;
        expect(revealed, 25);

        // 5-10 monster lairs
        final lairs = map.cells
            .where((c) => c.content == CellContentType.monsterLair)
            .length;
        expect(lairs, greaterThanOrEqualTo(5));
        expect(lairs, lessThanOrEqualTo(10));

        // Base zone empty of content
        for (var dy = -2; dy <= 2; dy++) {
          for (var dx = -2; dx <= 2; dx++) {
            final x = map.playerBaseX + dx;
            final y = map.playerBaseY + dy;
            if (x < 0 || x >= 20 || y < 0 || y >= 20) continue;
            expect(map.cellAt(x, y).content, CellContentType.empty);
          }
        }
      });
    }
  });
}
