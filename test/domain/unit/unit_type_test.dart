import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('UnitType', () {
    test('has 6 values', () {
      expect(UnitType.values.length, 6);
    });

    test('all values are distinct', () {
      expect(UnitType.values.toSet().length, 6);
    });
  });
}
