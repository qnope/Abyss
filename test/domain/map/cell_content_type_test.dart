import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/cell_content_type.dart';

void main() {
  group('CellContentType', () {
    test('has all 7 values', () {
      expect(CellContentType.values.length, 7);
      expect(CellContentType.values, contains(CellContentType.empty));
      expect(CellContentType.values, contains(CellContentType.resourceBonus));
      expect(CellContentType.values, contains(CellContentType.ruins));
      expect(CellContentType.values, contains(CellContentType.monsterLair));
      expect(
        CellContentType.values,
        contains(CellContentType.transitionBase),
      );
      expect(CellContentType.values, contains(CellContentType.passage));
      expect(
        CellContentType.values,
        contains(CellContentType.volcanicKernel),
      );
    });

    test('values have correct indices', () {
      expect(CellContentType.empty.index, 0);
      expect(CellContentType.resourceBonus.index, 1);
      expect(CellContentType.ruins.index, 2);
      expect(CellContentType.monsterLair.index, 3);
    });

    test('volcanicKernel exists', () {
      expect(CellContentType.volcanicKernel, isNotNull);
      expect(CellContentType.volcanicKernel.index, 6);
    });
  });
}
