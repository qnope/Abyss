import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/cell_content_type.dart';
import 'package:abyss/domain/map_generator.dart';

void main() {
  group('MapGenerator', () {
    test('generated map is 20x20', () {
      final map = MapGenerator.generate(seed: 42);
      expect(map.width, 20);
      expect(map.height, 20);
      expect(map.cells.length, 400);
    });

    test('player base is within 2 of center', () {
      final map = MapGenerator.generate(seed: 42);
      expect((map.playerBaseX - 10).abs(), lessThanOrEqualTo(2));
      expect((map.playerBaseY - 10).abs(), lessThanOrEqualTo(2));
    });

    test('base cell has empty content', () {
      final map = MapGenerator.generate(seed: 42);
      final base = map.cellAt(map.playerBaseX, map.playerBaseY);
      expect(base.content, CellContentType.empty);
    });

    test('exactly 25 cells are revealed', () {
      final map = MapGenerator.generate(seed: 42);
      final revealed = map.cells.where((c) => c.isRevealed).length;
      expect(revealed, 25);
    });

    test('revealed cells match Chebyshev distance <= 2', () {
      final map = MapGenerator.generate(seed: 42);
      for (var y = 0; y < 20; y++) {
        for (var x = 0; x < 20; x++) {
          final dist = max(
            (x - map.playerBaseX).abs(),
            (y - map.playerBaseY).abs(),
          );
          final cell = map.cellAt(x, y);
          if (dist <= 2) {
            expect(cell.isRevealed, true, reason: '($x,$y)');
          } else {
            expect(cell.isRevealed, false, reason: '($x,$y)');
          }
        }
      }
    });

    test('same seed produces identical maps', () {
      final a = MapGenerator.generate(seed: 99);
      final b = MapGenerator.generate(seed: 99);
      expect(a.playerBaseX, b.playerBaseX);
      expect(a.playerBaseY, b.playerBaseY);
      for (var i = 0; i < 400; i++) {
        expect(a.cells[i].terrain, b.cells[i].terrain);
        expect(a.cells[i].content, b.cells[i].content);
      }
    });

    test('seed is stored in GameMap', () {
      final map = MapGenerator.generate(seed: 123);
      expect(map.seed, 123);
    });
  });
}
