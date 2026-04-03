import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action_executor.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/upgrade_building_action.dart';

Game _createGame({int coral = 80, int ore = 50, int hqLevel = 0}) {
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
      BuildingType.headquarters:
          Building(type: BuildingType.headquarters, level: hqLevel),
    },
  );
}

void main() {
  group('ActionExecutor', () {
    late ActionExecutor executor;
    late UpgradeBuildingAction action;

    setUp(() {
      executor = ActionExecutor();
      action = UpgradeBuildingAction(buildingType: BuildingType.headquarters);
    });

    test('execute valid UpgradeBuildingAction deducts resources and levels up',
        () {
      final game = _createGame();

      final result = executor.execute(action, game);

      expect(result.isSuccess, true);
      expect(game.resources[ResourceType.coral]!.amount, 50);
      expect(game.resources[ResourceType.ore]!.amount, 30);
      expect(game.buildings[BuildingType.headquarters]!.level, 1);
    });

    test('execute with insufficient resources returns failure', () {
      final game = _createGame(coral: 10, ore: 5);

      final result = executor.execute(action, game);

      expect(result.isSuccess, false);
      expect(result.reason, isNotNull);
      expect(game.resources[ResourceType.coral]!.amount, 10);
      expect(game.resources[ResourceType.ore]!.amount, 5);
      expect(game.buildings[BuildingType.headquarters]!.level, 0);
    });

    test('execute at max level returns failure', () {
      final game = _createGame(hqLevel: 10);

      final result = executor.execute(action, game);

      expect(result.isSuccess, false);
      expect(result.reason, isNotNull);
      expect(game.buildings[BuildingType.headquarters]!.level, 10);
      expect(game.resources[ResourceType.coral]!.amount, 80);
      expect(game.resources[ResourceType.ore]!.amount, 50);
    });
  });

  group('Integration — full flow', () {
    late ActionExecutor executor;

    setUp(() {
      executor = ActionExecutor();
    });

    test('create action, execute, verify game state', () {
      final game = _createGame();
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final result = executor.execute(action, game);

      expect(result.isSuccess, true);
      expect(game.resources[ResourceType.coral]!.amount, 50);
      expect(game.resources[ResourceType.ore]!.amount, 30);
      expect(game.buildings[BuildingType.headquarters]!.level, 1);
      expect(game.resources[ResourceType.algae]!.amount, 100);
      expect(game.resources[ResourceType.energy]!.amount, 60);
      expect(game.resources[ResourceType.pearl]!.amount, 5);
    });

    test('same action on identical games produces identical outcomes', () {
      final gameA = _createGame();
      final gameB = _createGame();
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final resultA = executor.execute(action, gameA);
      final resultB = executor.execute(action, gameB);

      expect(resultA.isSuccess, resultB.isSuccess);
      for (final type in ResourceType.values) {
        expect(
          gameA.resources[type]!.amount,
          gameB.resources[type]!.amount,
        );
      }
      expect(
        gameA.buildings[BuildingType.headquarters]!.level,
        gameB.buildings[BuildingType.headquarters]!.level,
      );
    });
  });
}
