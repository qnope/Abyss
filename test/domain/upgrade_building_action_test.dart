import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action_type.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/upgrade_building_action.dart';

void main() {
  late UpgradeBuildingAction action;

  setUp(() {
    action = UpgradeBuildingAction(
      buildingType: BuildingType.headquarters,
    );
  });

  Game makeGame({int coral = 80, int ore = 50, int level = 0}) {
    return Game(
      player: Player(name: 'Test'),
      resources: {
        ResourceType.algae: Resource(type: ResourceType.algae, amount: 100),
        ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
        ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
        ResourceType.energy: Resource(type: ResourceType.energy, amount: 60),
        ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 5),
      },
      buildings: {
        BuildingType.headquarters: Building(
          type: BuildingType.headquarters,
          level: level,
        ),
      },
    );
  }

  group('properties', () {
    test('type returns ActionType.upgradeBuilding', () {
      expect(action.type, ActionType.upgradeBuilding);
    });

    test('buildingType is correctly stored', () {
      expect(action.buildingType, BuildingType.headquarters);
    });

    test('description returns a readable string', () {
      expect(action.description, contains('headquarters'));
    });
  });

  group('validate', () {
    test('returns success when resources sufficient', () {
      final game = makeGame();
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when resources insufficient', () {
      final game = makeGame(coral: 10, ore: 5);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });

    test('returns failure when building at max level', () {
      final game = makeGame(level: 10);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });
  });

  group('execute', () {
    test('deducts resources and increments level', () {
      final game = makeGame();
      final result = action.execute(game);
      expect(result.isSuccess, isTrue);
      expect(game.resources[ResourceType.coral]!.amount, 50);
      expect(game.resources[ResourceType.ore]!.amount, 30);
      expect(game.buildings[BuildingType.headquarters]!.level, 1);
    });

    test('returns failure without modifying when resources insufficient', () {
      final game = makeGame(coral: 10, ore: 5);
      final result = action.execute(game);
      expect(result.isSuccess, isFalse);
      expect(game.resources[ResourceType.coral]!.amount, 10);
      expect(game.resources[ResourceType.ore]!.amount, 5);
      expect(game.buildings[BuildingType.headquarters]!.level, 0);
    });

    test('returns failure without modifying when at max level', () {
      final game = makeGame(level: 10);
      final result = action.execute(game);
      expect(result.isSuccess, isFalse);
      expect(game.buildings[BuildingType.headquarters]!.level, 10);
    });
  });
}
