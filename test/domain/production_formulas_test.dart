import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/production_formulas.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('productionFormulas', () {
    test('algaeFarm returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.algaeFarm]!;
      expect(formula.compute(1), 50);
      expect(formula.compute(2), 140);
      expect(formula.compute(3), 290);
      expect(formula.compute(4), 500);
      expect(formula.compute(5), 770);
    });

    test('coralMine returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.coralMine]!;
      expect(formula.compute(1), 40);
      expect(formula.compute(2), 100);
      expect(formula.compute(3), 200);
      expect(formula.compute(4), 340);
      expect(formula.compute(5), 520);
    });

    test('oreExtractor returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.oreExtractor]!;
      expect(formula.compute(1), 30);
      expect(formula.compute(2), 90);
      expect(formula.compute(3), 190);
      expect(formula.compute(4), 330);
      expect(formula.compute(5), 510);
    });

    test('solarPanel returns expected values for levels 1-5', () {
      final formula = productionFormulas[BuildingType.solarPanel]!;
      expect(formula.compute(1), 6);
      expect(formula.compute(2), 18);
      expect(formula.compute(3), 38);
      expect(formula.compute(4), 66);
      expect(formula.compute(5), 102);
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
