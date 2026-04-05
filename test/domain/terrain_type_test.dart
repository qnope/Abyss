import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/terrain_type.dart';

void main() {
  group('TerrainType', () {
    test('has exactly 4 values', () {
      expect(TerrainType.values.length, 4);
    });

    test('contains all expected types', () {
      expect(TerrainType.values, contains(TerrainType.plain));
      expect(TerrainType.values, contains(TerrainType.reef));
      expect(TerrainType.values, contains(TerrainType.rock));
      expect(TerrainType.values, contains(TerrainType.fault));
    });
  });
}
