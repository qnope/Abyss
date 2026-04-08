import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
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
          a.map.cells[i].lair?.difficulty,
          b.map.cells[i].lair?.difficulty,
        );
        expect(
          a.map.cells[i].lair?.unitCount,
          b.map.cells[i].lair?.unitCount,
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
            .toList();
        expect(lairs.length, greaterThanOrEqualTo(5));
        expect(lairs.length, lessThanOrEqualTo(10));

        // Every lair has a stable, in-range unit count
        for (final cell in lairs) {
          expect(cell.lair, isNotNull);
          final lair = cell.lair!;
          switch (lair.difficulty) {
            case MonsterDifficulty.easy:
              expect(lair.unitCount, inInclusiveRange(20, 50));
            case MonsterDifficulty.medium:
              expect(lair.unitCount, inInclusiveRange(60, 100));
            case MonsterDifficulty.hard:
              expect(lair.unitCount, inInclusiveRange(120, 200));
          }
        }

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
