import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';
import 'package:abyss/domain/tile_content.dart';

void main() {
  group('MapTile', () {
    test('creates with required fields', () {
      final tile = MapTile(x: 5, y: 10, terrain: TerrainType.plain);
      expect(tile.x, 5);
      expect(tile.y, 10);
      expect(tile.terrain, TerrainType.plain);
      expect(tile.content, TileContent.empty);
      expect(tile.revealed, false);
    });

    test('creates with all fields', () {
      final tile = MapTile(
        x: 3,
        y: 7,
        terrain: TerrainType.rock,
        content: TileContent.monsterLevel2,
        revealed: true,
      );
      expect(tile.terrain, TerrainType.rock);
      expect(tile.content, TileContent.monsterLevel2);
      expect(tile.revealed, true);
    });

    test('revealed can be toggled', () {
      final tile = MapTile(x: 0, y: 0, terrain: TerrainType.reef);
      expect(tile.revealed, false);
      tile.revealed = true;
      expect(tile.revealed, true);
    });
  });
}
