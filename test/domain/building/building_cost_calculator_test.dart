import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';

void main() {
  late BuildingCostCalculator calculator;

  setUp(() {
    calculator = BuildingCostCalculator();
  });

  group('upgradeCost', () {
    test('HQ level 0->1: coral=30, ore=20', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 0);
      expect(cost[ResourceType.coral], 30);
      expect(cost[ResourceType.ore], 20);
    });

    test('HQ level 1->2: coral=60, ore=40', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 1);
      expect(cost[ResourceType.coral], 60);
      expect(cost[ResourceType.ore], 40);
    });

    test('HQ level 5->6: coral=780, ore=520', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 5);
      expect(cost[ResourceType.coral], 780);
      expect(cost[ResourceType.ore], 520);
    });

    test('HQ level 9->10: coral=2460, ore=1640', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 9);
      expect(cost[ResourceType.coral], 2460);
      expect(cost[ResourceType.ore], 1640);
    });

    test('HQ at max level (10): returns empty map', () {
      final cost = calculator.upgradeCost(BuildingType.headquarters, 10);
      expect(cost, isEmpty);
    });

    test('algaeFarm level 0->1: coral=20', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 0);
      expect(cost[ResourceType.coral], 20);
    });

    test('algaeFarm level 2->3: coral=100', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 2);
      expect(cost[ResourceType.coral], 100);
    });

    test('algaeFarm at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.algaeFarm, 5);
      expect(cost, isEmpty);
    });

    test('coralMine level 0->1: ore=15', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 0);
      expect(cost[ResourceType.ore], 15);
    });

    test('coralMine level 3->4: ore=150', () {
      final cost = calculator.upgradeCost(BuildingType.coralMine, 3);
      expect(cost[ResourceType.ore], 150);
    });

    test('oreExtractor level 0->1: coral=25, energy=15', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 0);
      expect(cost[ResourceType.coral], 25);
      expect(cost[ResourceType.energy], 15);
    });

    test('oreExtractor level 1->2: coral=50, energy=30', () {
      final cost = calculator.upgradeCost(BuildingType.oreExtractor, 1);
      expect(cost[ResourceType.coral], 50);
      expect(cost[ResourceType.energy], 30);
    });

    test('solarPanel level 0->1: coral=20, ore=15', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 0);
      expect(cost[ResourceType.coral], 20);
      expect(cost[ResourceType.ore], 15);
    });

    test('solarPanel level 4->5: coral=340, ore=255', () {
      final cost = calculator.upgradeCost(BuildingType.solarPanel, 4);
      expect(cost[ResourceType.coral], 340);
      expect(cost[ResourceType.ore], 255);
    });

    test('laboratory level 0->1: coral=25, ore=20', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 0);
      expect(cost[ResourceType.coral], 25);
      expect(cost[ResourceType.ore], 20);
    });

    test('laboratory at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.laboratory, 5);
      expect(cost, isEmpty);
    });

    test('barracks level 0->1: coral=20, ore=25, energy=10', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 0);
      expect(cost[ResourceType.coral], 20);
      expect(cost[ResourceType.ore], 25);
      expect(cost[ResourceType.energy], 10);
    });

    test('barracks at max level 5: empty', () {
      final cost = calculator.upgradeCost(BuildingType.barracks, 5);
      expect(cost, isEmpty);
    });
  });

  group('maxLevel', () {
    test('HQ is 10', () {
      expect(calculator.maxLevel(BuildingType.headquarters), 10);
    });

    test('algaeFarm is 5', () {
      expect(calculator.maxLevel(BuildingType.algaeFarm), 5);
    });

    test('coralMine is 5', () {
      expect(calculator.maxLevel(BuildingType.coralMine), 5);
    });

    test('oreExtractor is 5', () {
      expect(calculator.maxLevel(BuildingType.oreExtractor), 5);
    });

    test('solarPanel is 5', () {
      expect(calculator.maxLevel(BuildingType.solarPanel), 5);
    });

    test('laboratory is 5', () {
      expect(calculator.maxLevel(BuildingType.laboratory), 5);
    });

    test('barracks is 5', () {
      expect(calculator.maxLevel(BuildingType.barracks), 5);
    });
  });
}
