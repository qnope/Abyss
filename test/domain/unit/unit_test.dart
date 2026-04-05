import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('Unit', () {
    test('default count is 0', () {
      final unit = Unit(type: UnitType.scout);
      expect(unit.count, 0);
    });

    test('count is mutable', () {
      final unit = Unit(type: UnitType.scout);
      unit.count = 5;
      expect(unit.count, 5);
    });

    test('custom count at construction', () {
      final unit = Unit(type: UnitType.guardian, count: 10);
      expect(unit.count, 10);
      expect(unit.type, UnitType.guardian);
    });
  });
}
