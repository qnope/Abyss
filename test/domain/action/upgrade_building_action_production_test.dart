import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';

({Game game, Player player}) makeProductionScenario({
  int coral = 200,
  int ore = 200,
  int energy = 200,
  int algae = 200,
  int hqLevel = 1,
  int algaeFarmLevel = 0,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      ResourceType.algae: Resource(type: ResourceType.algae, amount: algae),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 5),
    },
    buildings: {
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: hqLevel),
      BuildingType.algaeFarm:
          Building(type: BuildingType.algaeFarm, level: algaeFarmLevel),
      BuildingType.coralMine:
          Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor:
          Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel:
          Building(type: BuildingType.solarPanel, level: 0),
    },
  );
  final game = Game(
    humanPlayerId: player.id,
    players: {player.id: player},
  );
  return (game: game, player: player);
}

void main() {
  group('production buildings', () {
    test('validate succeeds for algaeFarm with sufficient resources and HQ',
        () {
      final s = makeProductionScenario();
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isTrue);
    });

    test('validate fails for algaeFarm when HQ level too low', () {
      final s = makeProductionScenario(hqLevel: 0);
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });

    test('execute algaeFarm deducts coral and increments level', () {
      final s = makeProductionScenario();
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      action.execute(s.game, s.player);
      expect(s.player.resources[ResourceType.coral]!.amount, 180);
      expect(s.player.buildings[BuildingType.algaeFarm]!.level, 1);
    });

    test('execute algaeFarm increases production via calculator', () {
      final s = makeProductionScenario();
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
      action.execute(s.game, s.player);
      final production =
          ProductionCalculator.fromBuildings(s.player.buildings);
      expect(production[ResourceType.algae], 50);
    });

    test('execute algaeFarm twice cumulates production', () {
      final s = makeProductionScenario(hqLevel: 2);
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
      action.execute(s.game, s.player);
      action.execute(s.game, s.player);
      final production =
          ProductionCalculator.fromBuildings(s.player.buildings);
      expect(production[ResourceType.algae], 140);
    });

    test('execute HQ does not affect production', () {
      final s = makeProductionScenario();
      final before = ProductionCalculator.fromBuildings(s.player.buildings);
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);
      action.execute(s.game, s.player);
      final after = ProductionCalculator.fromBuildings(s.player.buildings);
      expect(after, equals(before));
    });

    test('validate fails for algaeFarm at max level 5', () {
      final s = makeProductionScenario(algaeFarmLevel: 5);
      final action = UpgradeBuildingAction(
        buildingType: BuildingType.algaeFarm,
      );
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });
  });
}
