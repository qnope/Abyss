import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_resolver.dart';

Game _game({
  Map<BuildingType, Building>? buildings,
  Map<ResourceType, Resource>? resources,
  int turn = 1,
}) {
  return Game(
    player: Player(name: 'Test'),
    turn: turn,
    buildings: buildings ?? Game.defaultBuildings(),
    resources: resources ?? Game.defaultResources(),
  );
}

void main() {
  late TurnResolver resolver;

  setUp(() => resolver = TurnResolver());

  group('Production application', () {
    test('single building produces correctly', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 2,
        ),
      });
      final before = game.resources[ResourceType.algae]!.amount;
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, before + 14);
      expect(result.changes.length, 1);
      expect(result.changes.first.produced, 14);
    });

    test('multiple buildings produce correctly', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 1,
        ),
        BuildingType.coralMine: Building(
          type: BuildingType.coralMine,
          level: 2,
        ),
      });
      resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, 105);
      expect(game.resources[ResourceType.coral]!.amount, 90);
    });

    test('turn counter increments', () {
      final game = _game();
      expect(game.turn, 1);
      resolver.resolve(game);
      expect(game.turn, 2);
    });
  });

  group('Storage capping', () {
    test('resource capped at maxStorage', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 498,
            maxStorage: 500,
          ),
        },
      );
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, 500);
      final change = result.changes.firstWhere(
        (c) => c.type == ResourceType.algae,
      );
      expect(change.wasCapped, isTrue);
    });

    test('resource not capped', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 100,
            maxStorage: 500,
          ),
        },
      );
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, 105);
      final change = result.changes.firstWhere(
        (c) => c.type == ResourceType.algae,
      );
      expect(change.wasCapped, isFalse);
    });

    test('already at max', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 500,
            maxStorage: 500,
          ),
        },
      );
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, 500);
      final change = result.changes.firstWhere(
        (c) => c.type == ResourceType.algae,
      );
      expect(change.wasCapped, isTrue);
    });
  });

  group('Edge cases', () {
    test('no production buildings returns empty changes', () {
      final game = _game();
      final result = resolver.resolve(game);
      expect(result.changes, isEmpty);
      expect(game.turn, 2);
    });

    test('pearl untouched after resolve', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 3,
        ),
      });
      final pearlBefore = game.resources[ResourceType.pearl]!.amount;
      resolver.resolve(game);
      expect(game.resources[ResourceType.pearl]!.amount, pearlBefore);
    });

    test('changes only contains resources with production > 0', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 1,
        ),
      });
      final result = resolver.resolve(game);
      expect(result.changes.length, 1);
      expect(result.changes.first.type, ResourceType.algae);
    });
  });
}
