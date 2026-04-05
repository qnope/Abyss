import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  GameMap makeMap() {
    final cells = List.generate(
      400,
      (i) => MapCell(terrain: TerrainType.reef),
    );
    return GameMap(
      width: 20,
      height: 20,
      cells: cells,
      playerBaseX: 10,
      playerBaseY: 10,
      seed: 42,
    );
  }

  group('GameMap', () {
    test('construction with 20x20 grid', () {
      final map = makeMap();
      expect(map.width, 20);
      expect(map.height, 20);
      expect(map.cells.length, 400);
      expect(map.playerBaseX, 10);
      expect(map.playerBaseY, 10);
      expect(map.seed, 42);
    });

    test('cellAt returns correct cell', () {
      final map = makeMap();
      final cell = MapCell(terrain: TerrainType.plain);
      map.cells[5 * 20 + 3] = cell;
      expect(map.cellAt(3, 5).terrain, TerrainType.plain);
    });

    test('setCell overwrites correct cell', () {
      final map = makeMap();
      final cell = MapCell(terrain: TerrainType.rock);
      map.setCell(7, 12, cell);
      expect(map.cellAt(7, 12).terrain, TerrainType.rock);
    });

    test('cellAt handles corners', () {
      final map = makeMap();
      map.setCell(0, 0, MapCell(terrain: TerrainType.fault));
      map.setCell(19, 19, MapCell(terrain: TerrainType.plain));
      expect(map.cellAt(0, 0).terrain, TerrainType.fault);
      expect(map.cellAt(19, 19).terrain, TerrainType.plain);
    });
  });
}
