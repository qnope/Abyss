import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_type.dart';

void main() {
  group('TerrainType', () {
    test('has only plain', () {
      expect(TerrainType.values.length, 1);
      expect(TerrainType.values, contains(TerrainType.plain));
    });
  });
}
