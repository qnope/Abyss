import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/upgrade_building_action.dart';

Game makeProductionGame({
  int coral = 200,
  int ore = 200,
  int energy = 200,
  int algae = 200,
  int hqLevel = 1,
  int algaeFarmLevel = 0,
}) {
  return Game(
    player: Player(name: 'Test'),
    resources: {
      ResourceType.algae: Resource(
        type: ResourceType.algae,
        amount: algae,
      ),
      ResourceType.coral: Resource(
        type: ResourceType.coral,
        amount: coral,
      ),
      ResourceType.ore: Resource(
        type: ResourceType.ore,
        amount: ore,
      ),
      ResourceType.energy: Resource(
        type: ResourceType.energy,
        amount: energy,
      ),
      ResourceType.pearl: Resource(
        type: ResourceType.pearl,
        amount: 5,
      ),
    },
    buildings: {
      BuildingType.headquarters: Building(
        type: BuildingType.headquarters,
        level: hqLevel,
      ),
      BuildingType.algaeFarm: Building(
        type: BuildingType.algaeFarm,
        level: algaeFarmLevel,
      ),
      BuildingType.coralMine: Building(
        type: BuildingType.coralMine,
        level: 0,
      ),
      BuildingType.oreExtractor: Building(
        type: BuildingType.oreExtractor,
        level: 0,
      ),
      BuildingType.solarPanel: Building(
        type: BuildingType.solarPanel,
        level: 0,
      ),
    },
  );
}

void main() {
  group('production buildings', () {
    test('validate succeeds for algaeFarm with sufficient resources and HQ',
        () {
      final game = makeProductionGame();
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });

    test('validate fails for algaeFarm when HQ level too low', () {
      final game = makeProductionGame(hqLevel: 0);
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });

    test('execute algaeFarm deducts coral and increments level', () {
      final game = makeProductionGame();
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      action.execute(game);
      expect(game.resources[ResourceType.coral]!.amount, 180);
      expect(game.buildings[BuildingType.algaeFarm]!.level, 1);
    });

    test('execute algaeFarm increases production via calculator', () {
      final game = makeProductionGame();
      final action = UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
      action.execute(game);
      final production = ProductionCalculator.fromBuildings(game.buildings);
      expect(production[ResourceType.algae], 50);
    });

    test('execute algaeFarm twice cumulates production', () {
      final game = makeProductionGame(hqLevel: 2);
      final action = UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
      action.execute(game);
      action.execute(game);
      final production = ProductionCalculator.fromBuildings(game.buildings);
      expect(production[ResourceType.algae], 140);
    });

    test('execute HQ does not affect production', () {
      final game = makeProductionGame();
      final before = ProductionCalculator.fromBuildings(game.buildings);
      final action = UpgradeBuildingAction(buildingType: BuildingType.headquarters);
      action.execute(game);
      final after = ProductionCalculator.fromBuildings(game.buildings);
      expect(after, equals(before));
    });

    test('validate fails for algaeFarm at max level 5', () {
      final game = makeProductionGame(algaeFarmLevel: 5);
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });
  });
}
