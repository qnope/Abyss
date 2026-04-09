import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_deactivator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:flutter_test/flutter_test.dart';

Map<BuildingType, Building> _buildings(Map<BuildingType, int> levels) {
  return {
    for (final entry in levels.entries)
      entry.key: Building(type: entry.key, level: entry.value),
  };
}

void main() {
  group('deactivate', () {
    test('no deficit returns empty list', () {
      // consumption: HQ lvl2=6, algae lvl3=6, solar lvl5=5 → 17
      // production=50, stock=0 → available=50
      final buildings = _buildings({
        BuildingType.headquarters: 2,
        BuildingType.algaeFarm: 3,
        BuildingType.solarPanel: 5,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 50,
        energyStock: 0,
      );
      expect(result, isEmpty);
    });

    test('exact balance returns empty list', () {
      // HQ lvl1=3, algae lvl1=2 → consumption=5
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.algaeFarm: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 3,
        energyStock: 2,
      );
      expect(result, isEmpty);
    });

    test('disables ore extractor first', () {
      // HQ lvl1=3, oreExtractor lvl1=3 → consumption=6
      // production=0, stock=4 → available=4, deficit=2
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 4,
      );
      expect(result, [BuildingType.oreExtractor]);
    });

    test('disables multiple buildings in priority order', () {
      // HQ lvl1=3, oreExtractor lvl1=3, coralMine lvl1=2 → 8
      // available=2
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.oreExtractor: 1,
        BuildingType.coralMine: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 2,
        energyStock: 0,
      );
      expect(result, [BuildingType.oreExtractor, BuildingType.coralMine]);
    });

    test('never disables headquarters', () {
      // HQ lvl5=15, huge deficit, available=0
      final buildings = _buildings({BuildingType.headquarters: 5});
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 0,
      );
      expect(result, isNot(contains(BuildingType.headquarters)));
    });

    test('skips level 0 buildings', () {
      // HQ lvl1=3, oreExtractor lvl0=0, coralMine lvl1=2 → 5
      // available=2
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.oreExtractor: 0,
        BuildingType.coralMine: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 2,
        energyStock: 0,
      );
      expect(result, [BuildingType.coralMine]);
      expect(result, isNot(contains(BuildingType.oreExtractor)));
    });

    test('uses stock to cover deficit', () {
      // HQ lvl2=6, algae lvl2=4, coralMine lvl2=4 → 14
      // production=10, stock=20 → available=30
      final buildings = _buildings({
        BuildingType.headquarters: 2,
        BuildingType.algaeFarm: 2,
        BuildingType.coralMine: 2,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 10,
        energyStock: 20,
      );
      expect(result, isEmpty);
    });

    test('stock not enough triggers deactivation', () {
      // HQ lvl2=6, algae lvl2=4, oreExtractor lvl2=6 → 16
      // production=10, stock=5 → available=15, deficit=1
      final buildings = _buildings({
        BuildingType.headquarters: 2,
        BuildingType.algaeFarm: 2,
        BuildingType.oreExtractor: 2,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 10,
        energyStock: 5,
      );
      expect(result, [BuildingType.oreExtractor]);
    });

    test('all non-HQ buildings deactivated in extreme deficit', () {
      // All buildings at level 1, production=0, stock=0
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.solarPanel: 1,
        BuildingType.barracks: 1,
        BuildingType.laboratory: 1,
        BuildingType.algaeFarm: 1,
        BuildingType.coralMine: 1,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 0,
      );
      expect(result.length, 6);
      expect(result, isNot(contains(BuildingType.headquarters)));
    });

    test('solar panel disabled last (before HQ)', () {
      // All buildings at level 1 (no citadel), production=0, stock=0
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.solarPanel: 1,
        BuildingType.barracks: 1,
        BuildingType.laboratory: 1,
        BuildingType.algaeFarm: 1,
        BuildingType.coralMine: 1,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 0,
      );
      expect(result.last, BuildingType.solarPanel);
    });

    test('coral citadel is deactivated last when all buildings level 1', () {
      // All buildings at level 1 including citadel.
      // Consumption: HQ=3, citadel=1, solar=1, barracks=3, lab=4,
      //   algae=2, coralMine=2, ore=3 => total 19.
      // production=0, stock=0 => full deficit, every non-HQ must go down.
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.coralCitadel: 1,
        BuildingType.solarPanel: 1,
        BuildingType.barracks: 1,
        BuildingType.laboratory: 1,
        BuildingType.algaeFarm: 1,
        BuildingType.coralMine: 1,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 0,
      );
      expect(result.length, 7);
      expect(result, isNot(contains(BuildingType.headquarters)));
      expect(result.last, BuildingType.coralCitadel);
    });

    test('coral citadel is spared when ore extractor alone closes deficit', () {
      // HQ lvl1=3, citadel lvl1=1, oreExtractor lvl1=3 => total 7.
      // available = 4, deficit = 3. Deactivating ore extractor alone suffices.
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.coralCitadel: 1,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 4,
        energyStock: 0,
      );
      expect(result, [BuildingType.oreExtractor]);
      expect(result, isNot(contains(BuildingType.coralCitadel)));
    });

    test('skips level 0 coral citadel', () {
      // HQ lvl1=3, citadel lvl0=0, oreExtractor lvl1=3 => total 6.
      // available=0, deficit=6 — everything non-HQ except level-0 citadel goes.
      final buildings = _buildings({
        BuildingType.headquarters: 1,
        BuildingType.coralCitadel: 0,
        BuildingType.oreExtractor: 1,
      });
      final result = BuildingDeactivator.deactivate(
        buildings: buildings,
        energyProduction: 0,
        energyStock: 0,
      );
      expect(result, [BuildingType.oreExtractor]);
      expect(result, isNot(contains(BuildingType.coralCitadel)));
    });
  });
}
