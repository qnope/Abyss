import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('TerrainType', () {
    test('has all 4 values', () {
      expect(TerrainType.values.length, 4);
      expect(TerrainType.values, contains(TerrainType.reef));
      expect(TerrainType.values, contains(TerrainType.plain));
      expect(TerrainType.values, contains(TerrainType.rock));
      expect(TerrainType.values, contains(TerrainType.fault));
    });

    test('values have correct indices', () {
      expect(TerrainType.reef.index, 0);
      expect(TerrainType.plain.index, 1);
      expect(TerrainType.rock.index, 2);
      expect(TerrainType.fault.index, 3);
    });
  });
}
