import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  GameMap makeMap() {
    final cells = List.generate(
      400,
      (i) => MapCell(terrain: TerrainType.plain),
    );
    return GameMap(
      width: 20,
      height: 20,
      cells: cells,
      seed: 42,
    );
  }

  group('GameMap construction', () {
    test('constructs without base coordinates', () {
      final map = makeMap();
      expect(map.width, 20);
      expect(map.height, 20);
      expect(map.cells.length, 400);
      expect(map.seed, 42);
    });
  });

  group('GameMap cellAt / setCell', () {
    test('cellAt retrieves the correct cell', () {
      final map = makeMap();
      final marker = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.ruins,
      );
      map.cells[5 * 20 + 3] = marker;
      expect(map.cellAt(3, 5).content, CellContentType.ruins);
    });

    test('setCell overwrites the correct cell', () {
      final map = makeMap();
      final marker = MapCell(
        terrain: TerrainType.plain,
        content: CellContentType.monsterLair,
      );
      map.setCell(7, 12, marker);
      expect(map.cellAt(7, 12).content, CellContentType.monsterLair);
    });

    test('cellAt handles corners', () {
      final map = makeMap();
      map.setCell(
        0,
        0,
        MapCell(terrain: TerrainType.plain, content: CellContentType.ruins),
      );
      map.setCell(
        19,
        19,
        MapCell(terrain: TerrainType.plain, content: CellContentType.empty),
      );
      expect(map.cellAt(0, 0).content, CellContentType.ruins);
      expect(map.cellAt(19, 19).content, CellContentType.empty);
    });
  });
}
