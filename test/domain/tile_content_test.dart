import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/tile_content.dart';

void main() {
  group('TileContent', () {
    test('has exactly 6 values', () {
      expect(TileContent.values.length, 6);
    });

    test('contains all expected types', () {
      expect(TileContent.values, contains(TileContent.empty));
      expect(TileContent.values, contains(TileContent.playerBase));
      expect(TileContent.values, contains(TileContent.monsterLevel1));
      expect(TileContent.values, contains(TileContent.monsterLevel2));
      expect(TileContent.values, contains(TileContent.monsterLevel3));
      expect(TileContent.values, contains(TileContent.enemy));
    });
  });
}
