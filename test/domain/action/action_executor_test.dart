import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';

({Game game, Player player}) _createScenario({
  int coral = 80,
  int ore = 50,
  int hqLevel = 0,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
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
  final game =
      Game(humanPlayerId: player.id, players: {player.id: player});
  return (game: game, player: player);
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
      final s = _createScenario();

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, true);
      expect(s.player.resources[ResourceType.coral]!.amount, 50);
      expect(s.player.resources[ResourceType.ore]!.amount, 30);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 1);
    });

    test('execute with insufficient resources returns failure', () {
      final s = _createScenario(coral: 10, ore: 5);

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, false);
      expect(result.reason, isNotNull);
      expect(s.player.resources[ResourceType.coral]!.amount, 10);
      expect(s.player.resources[ResourceType.ore]!.amount, 5);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 0);
    });

    test('execute at max level returns failure', () {
      final s = _createScenario(hqLevel: 10);

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, false);
      expect(result.reason, isNotNull);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 10);
      expect(s.player.resources[ResourceType.coral]!.amount, 80);
      expect(s.player.resources[ResourceType.ore]!.amount, 50);
    });
  });

  group('Integration — full flow', () {
    late ActionExecutor executor;

    setUp(() {
      executor = ActionExecutor();
    });

    test('create action, execute, verify state', () {
      final s = _createScenario();
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final result = executor.execute(action, s.game, s.player);

      expect(result.isSuccess, true);
      expect(s.player.resources[ResourceType.coral]!.amount, 50);
      expect(s.player.resources[ResourceType.ore]!.amount, 30);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 1);
      expect(s.player.resources[ResourceType.algae]!.amount, 100);
      expect(s.player.resources[ResourceType.energy]!.amount, 60);
      expect(s.player.resources[ResourceType.pearl]!.amount, 5);
    });

    test('same action on identical scenarios produces identical outcomes', () {
      final a = _createScenario();
      final b = _createScenario();
      final action =
          UpgradeBuildingAction(buildingType: BuildingType.headquarters);

      final resultA = executor.execute(action, a.game, a.player);
      final resultB = executor.execute(action, b.game, b.player);

      expect(resultA.isSuccess, resultB.isSuccess);
      for (final type in ResourceType.values) {
        expect(
          a.player.resources[type]!.amount,
          b.player.resources[type]!.amount,
        );
      }
      expect(
        a.player.buildings[BuildingType.headquarters]!.level,
        b.player.buildings[BuildingType.headquarters]!.level,
      );
    });
  });
}
