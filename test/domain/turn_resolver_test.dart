import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/turn_resolver.dart';
import 'package:abyss/domain/unit.dart';
import 'package:abyss/domain/unit_type.dart';

Game _game({
  Map<BuildingType, Building>? buildings,
  Map<ResourceType, Resource>? resources,
  Map<UnitType, Unit>? units,
  List<UnitType>? recruitedUnitTypes,
  int turn = 1,
}) {
  return Game(
    player: Player(name: 'Test'),
    turn: turn,
    buildings: buildings ?? Game.defaultBuildings(),
    resources: resources ?? Game.defaultResources(),
    units: units,
    recruitedUnitTypes: recruitedUnitTypes,
  );
}

void main() {
  late TurnResolver resolver;
  setUp(() => resolver = TurnResolver());

  group('Production application', () {
    test('single building produces correctly', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 2),
      });
      final result = resolver.resolve(game);
      final c = result.changes.first;
      expect(c.beforeAmount, 100);
      expect(c.produced, 140);
      expect(c.afterAmount, 240);
      expect(game.resources[ResourceType.algae]!.amount, 240);
    });
    test('multiple buildings produce correctly', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1),
        BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 2),
      });
      resolver.resolve(game);
      expect(game.resources[ResourceType.algae]!.amount, 150);
      expect(game.resources[ResourceType.coral]!.amount, 180);
    });
    test('turn counter increments', () {
      final game = _game();
      resolver.resolve(game);
      expect(game.turn, 2);
    });
  });

  group('Storage capping', () {
    test('resource capped at maxStorage', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        resources: {...Game.defaultResources(),
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 498, maxStorage: 500)},
      );
      final result = resolver.resolve(game);
      final c = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.beforeAmount, 498);
      expect(c.afterAmount, 500);
      expect(c.wasCapped, isTrue);
    });
    test('resource not capped', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        resources: {...Game.defaultResources(),
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 100, maxStorage: 5000)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.wasCapped, isFalse);
    });
    test('already at max', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        resources: {...Game.defaultResources(),
          ResourceType.algae: Resource(type: ResourceType.algae, amount: 500, maxStorage: 500)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.beforeAmount, 500);
      expect(c.afterAmount, 500);
      expect(c.wasCapped, isTrue);
    });
  });

  group('Maintenance deduction', () {
    test('maintenance reduces net production', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 10)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 40); // 50 prod - 10 maintenance
      expect(c.afterAmount, 140);
    });
    test('maintenance exceeding production floors at zero', () {
      final game = _game(
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 100)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, -100);
      expect(c.afterAmount, 0);
    });
    test('net production shown in changes', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 5)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 45); // 50 - 5
    });
  });

  group('Turn tracking', () {
    test('previousTurn and newTurn are correct', () {
      final game = _game(turn: 5);
      final result = resolver.resolve(game);
      expect(result.previousTurn, 5);
      expect(result.newTurn, 6);
    });
    test('hadRecruitedUnits true when units recruited', () {
      final game = _game(recruitedUnitTypes: [UnitType.scout]);
      expect(resolver.resolve(game).hadRecruitedUnits, isTrue);
    });
    test('hadRecruitedUnits false when no recruitment', () {
      final game = _game();
      expect(resolver.resolve(game).hadRecruitedUnits, isFalse);
    });
  });

  group('Edge cases', () {
    test('no production buildings returns empty changes', () {
      final game = _game();
      final result = resolver.resolve(game);
      expect(result.changes, isEmpty);
      expect(game.turn, 2);
    });
  });
}
