import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';

void main() {
  group('TerrainTypeExtensions', () {
    test('each terrain has a non-empty label', () {
      for (final t in TerrainType.values) {
        expect(t.label, isNotEmpty);
      }
    });

    test('each terrain has a valid svgPath', () {
      for (final t in TerrainType.values) {
        expect(t.svgPath, startsWith('assets/icons/terrain/'));
        expect(t.svgPath, endsWith('.svg'));
      }
    });

    test('reef and plain are not opaque', () {
      expect(TerrainType.reef.isOpaque, false);
      expect(TerrainType.plain.isOpaque, false);
    });

    test('rock and fault are opaque', () {
      expect(TerrainType.rock.isOpaque, true);
      expect(TerrainType.fault.isOpaque, true);
    });

    test('each terrain has a color', () {
      for (final t in TerrainType.values) {
        expect(t.color, isNotNull);
      }
    });
  });
}
