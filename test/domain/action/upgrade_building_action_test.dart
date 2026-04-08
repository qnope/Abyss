import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';

void main() {
  late UpgradeBuildingAction action;

  setUp(() {
    action = UpgradeBuildingAction(
      buildingType: BuildingType.headquarters,
    );
  });

  ({Game game, Player player}) makeScenario({
    int coral = 80,
    int ore = 50,
    int level = 0,
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
        BuildingType.headquarters: Building(
          type: BuildingType.headquarters,
          level: level,
        ),
      },
    );
    final game = Game(
      humanPlayerId: player.id,
      players: {player.id: player},
    );
    return (game: game, player: player);
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
      final s = makeScenario();
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when resources insufficient', () {
      final s = makeScenario(coral: 10, ore: 5);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });

    test('returns failure when building at max level', () {
      final s = makeScenario(level: 10);
      final result = action.validate(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(result.reason, isNotNull);
    });
  });

  group('execute', () {
    test('deducts resources and increments level', () {
      final s = makeScenario();
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isTrue);
      expect(s.player.resources[ResourceType.coral]!.amount, 50);
      expect(s.player.resources[ResourceType.ore]!.amount, 30);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 1);
    });

    test('returns failure without modifying when resources insufficient', () {
      final s = makeScenario(coral: 10, ore: 5);
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(s.player.resources[ResourceType.coral]!.amount, 10);
      expect(s.player.resources[ResourceType.ore]!.amount, 5);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 0);
    });

    test('returns failure without modifying when at max level', () {
      final s = makeScenario(level: 10);
      final result = action.execute(s.game, s.player);
      expect(result.isSuccess, isFalse);
      expect(s.player.buildings[BuildingType.headquarters]!.level, 10);
    });
  });
}
