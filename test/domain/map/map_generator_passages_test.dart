import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_generator.dart';

void main() {
  group('MapGenerator reserved passages', () {
    test('reserved passages become passage cells with correct name', () {
      final result = MapGenerator.generate(
        seed: 42,
        level: 2,
        reservedPassages: {
          GridPosition(x: 5, y: 5): 'Faille Alpha',
        },
      );
      final cell = result.map.cellAt(5, 5);
      expect(cell.content, CellContentType.passage);
      expect(cell.passageName, 'Faille Alpha');
    });

    test('reserved passage at base position is skipped', () {
      final ref = MapGenerator.generate(seed: 42);
      final baseX = ref.baseX;
      final baseY = ref.baseY;

      final result = MapGenerator.generate(
        seed: 42,
        reservedPassages: {
          GridPosition(x: baseX, y: baseY): 'Should Skip',
        },
      );
      final base = result.map.cellAt(baseX, baseY);
      expect(base.content, CellContentType.empty);
    });

    test('no content or transition base placed at reserved positions',
        () {
      final reserved = {
        GridPosition(x: 0, y: 0): 'P1',
        GridPosition(x: 19, y: 0): 'P2',
        GridPosition(x: 0, y: 19): 'P3',
        GridPosition(x: 19, y: 19): 'P4',
      };
      final result = MapGenerator.generate(
        seed: 42,
        level: 1,
        reservedPassages: reserved,
      );
      const forbidden = {
        CellContentType.monsterLair,
        CellContentType.resourceBonus,
        CellContentType.ruins,
        CellContentType.transitionBase,
      };
      for (final pos in reserved.keys) {
        final cell = result.map.cellAt(pos.x, pos.y);
        expect(
          forbidden.contains(cell.content),
          isFalse,
          reason: 'Cell (${ pos.x}, ${ pos.y}) has ${cell.content}',
        );
      }
    });
  });
}
