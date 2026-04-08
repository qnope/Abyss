import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';

void main() {
  group('MapGenerator.generate', () {
    test('returns a 20x20 map with matching cells length', () {
      final result = MapGenerator.generate(seed: 42);
      expect(result.map.width, 20);
      expect(result.map.height, 20);
      expect(result.map.cells.length, 400);
    });

    test('baseX / baseY are inside map bounds', () {
      final result = MapGenerator.generate(seed: 42);
      expect(result.baseX, greaterThanOrEqualTo(0));
      expect(result.baseX, lessThan(result.map.width));
      expect(result.baseY, greaterThanOrEqualTo(0));
      expect(result.baseY, lessThan(result.map.height));
    });

    test('base cell content is empty', () {
      final result = MapGenerator.generate(seed: 42);
      final base = result.map.cellAt(result.baseX, result.baseY);
      expect(base.content, CellContentType.empty);
    });

    test('seed is stored on the generated map', () {
      final result = MapGenerator.generate(seed: 123);
      expect(result.map.seed, 123);
    });

    test('same seed produces identical maps (deterministic)', () {
      final a = MapGenerator.generate(seed: 99);
      final b = MapGenerator.generate(seed: 99);
      expect(a.baseX, b.baseX);
      expect(a.baseY, b.baseY);
      expect(a.map.seed, b.map.seed);
      for (var i = 0; i < 400; i++) {
        expect(a.map.cells[i].terrain, b.map.cells[i].terrain);
        expect(a.map.cells[i].content, b.map.cells[i].content);
        expect(a.map.cells[i].monsterDifficulty,
            b.map.cells[i].monsterDifficulty);
      }
    });

    test('every cell is well-formed (no fog-of-war residue)', () {
      final result = MapGenerator.generate(seed: 42);
      for (final cell in result.map.cells) {
        expect(cell.terrain, isNotNull);
        expect(cell.content, isNotNull);
        expect(cell.collectedBy, isNull);
      }
    });
  });
}
