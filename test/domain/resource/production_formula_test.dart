import 'package:abyss/domain/resource/production_formula.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductionFormula', () {
    test('3*level²+2 returns expected values for levels 1-5', () {
      final formula = ProductionFormula(
        resourceType: ResourceType.algae,
        compute: (level) => 3 * level * level + 2,
      );

      expect(formula.compute(1), 5);
      expect(formula.compute(2), 14);
      expect(formula.compute(3), 29);
      expect(formula.compute(4), 50);
      expect(formula.compute(5), 77);
    });

    test('level 0 returns 0', () {
      final formula = ProductionFormula(
        resourceType: ResourceType.algae,
        compute: (level) => 3 * level * level + 2,
      );

      expect(formula.compute(0), 0);
    });

    test('2*level²+1 returns expected values for levels 1-5', () {
      final formula = ProductionFormula(
        resourceType: ResourceType.ore,
        compute: (level) => 2 * level * level + 1,
      );

      expect(formula.compute(1), 3);
      expect(formula.compute(2), 9);
      expect(formula.compute(3), 19);
      expect(formula.compute(4), 33);
      expect(formula.compute(5), 51);
    });
  });
}
