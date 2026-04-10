import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_generator.dart';
import 'package:abyss/domain/map/transition_base_type.dart';

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
        expect(a.map.cells[i].lair?.difficulty,
            b.map.cells[i].lair?.difficulty);
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

    test('level 1 map has 4 failles', () {
      final result = MapGenerator.generate(seed: 42, level: 1);
      final bases = result.map.cells
          .where((c) => c.content == CellContentType.transitionBase)
          .toList();
      expect(bases.length, 4);
      for (final b in bases) {
        expect(b.transitionBase!.type, TransitionBaseType.faille);
      }
    });

    test('level 2 map has 3 cheminees', () {
      final result = MapGenerator.generate(seed: 42, level: 2);
      final bases = result.map.cells
          .where((c) => c.content == CellContentType.transitionBase)
          .toList();
      expect(bases.length, 3);
      for (final b in bases) {
        expect(
          b.transitionBase!.type, TransitionBaseType.cheminee,
        );
      }
    });

    test('level 3 map has no transition bases', () {
      final result = MapGenerator.generate(seed: 42, level: 3);
      final count = result.map.cells
          .where((c) => c.content == CellContentType.transitionBase)
          .length;
      expect(count, 0);
    });

    test('base cell never has transition base', () {
      for (final level in [1, 2]) {
        final result = MapGenerator.generate(seed: 42, level: level);
        final base = result.map.cellAt(result.baseX, result.baseY);
        expect(
          base.content,
          isNot(CellContentType.transitionBase),
          reason: 'level=$level',
        );
      }
    });
  });
}
