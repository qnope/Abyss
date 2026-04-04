import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/production_formulas.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('productionFormulas', () {
    test('algaeFarm returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.algaeFarm]!;
      expect(formula.compute(1), 5);
      expect(formula.compute(2), 14);
      expect(formula.compute(3), 29);
      expect(formula.compute(4), 50);
      expect(formula.compute(5), 77);
    });

    test('coralMine returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.coralMine]!;
      expect(formula.compute(1), 4);
      expect(formula.compute(2), 10);
      expect(formula.compute(3), 20);
      expect(formula.compute(4), 34);
      expect(formula.compute(5), 52);
    });

    test('oreExtractor returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.oreExtractor]!;
      expect(formula.compute(1), 3);
      expect(formula.compute(2), 9);
      expect(formula.compute(3), 19);
      expect(formula.compute(4), 33);
      expect(formula.compute(5), 51);
    });

    test('solarPanel returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.solarPanel]!;
      expect(formula.compute(1), 3);
      expect(formula.compute(2), 9);
      expect(formula.compute(3), 19);
      expect(formula.compute(4), 33);
      expect(formula.compute(5), 51);
    });

    test('headquarters is not in the map', () {
      expect(
        productionFormulas.containsKey(BuildingType.headquarters),
        isFalse,
      );
    });

    test('each formula returns the correct resourceType', () {
      expect(
        productionFormulas[BuildingType.algaeFarm]!.resourceType,
        ResourceType.algae,
      );
      expect(
        productionFormulas[BuildingType.coralMine]!.resourceType,
        ResourceType.coral,
      );
      expect(
        productionFormulas[BuildingType.oreExtractor]!.resourceType,
        ResourceType.ore,
      );
      expect(
        productionFormulas[BuildingType.solarPanel]!.resourceType,
        ResourceType.energy,
      );
    });
  });
}
