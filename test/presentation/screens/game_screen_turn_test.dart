import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit.dart';
import 'package:abyss/domain/unit_type.dart';
import 'package:abyss/domain/production_calculator.dart';
import 'package:abyss/domain/maintenance_calculator.dart';
import 'package:abyss/domain/turn_resolver.dart';

Game _game({
  Map<BuildingType, Building>? buildings,
  Map<ResourceType, Resource>? resources,
  Map<UnitType, Unit>? units,
  List<UnitType>? recruitedUnitTypes,
  int turn = 1,
}) => Game(
  player: Player(name: 'Test'),
  turn: turn,
  buildings: buildings ?? Game.defaultBuildings(),
  resources: resources ?? Game.defaultResources(),
  units: units,
  recruitedUnitTypes: recruitedUnitTypes,
);

Map<ResourceType, int> _netProduction(Game game) {
  final prod = ProductionCalculator.fromBuildings(
    game.buildings, techBranches: game.techBranches,
  );
  final maint = MaintenanceCalculator.fromUnits(game.units);
  final net = <ResourceType, int>{};
  for (final type in {...prod.keys, ...maint.keys}) {
    net[type] = (prod[type] ?? 0) - (maint[type] ?? 0);
  }
  return net;
}

void main() {
  group('Turn flow data consistency', () {
    test('confirmation prediction matches resolver result', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 2),
        },
        units: {
          UnitType.scout: Unit(type: UnitType.scout, count: 10),
        },
      );
      final net = _netProduction(game);
      final algaeResource = game.resources[ResourceType.algae]!;
      final predicted = (algaeResource.amount + (net[ResourceType.algae] ?? 0))
          .clamp(0, algaeResource.maxStorage);

      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.afterAmount, predicted);
    });

    test('capping consistent between prediction and result', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 2),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae, amount: 4900, maxStorage: 5000,
          ),
        },
      );
      final net = _netProduction(game);
      final algae = game.resources[ResourceType.algae]!;
      final predictedCapped = algae.amount + (net[ResourceType.algae] ?? 0) > algae.maxStorage;

      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.wasCapped, predictedCapped);
      expect(change.afterAmount, algae.maxStorage);
    });

    test('maintenance deducted correctly through full flow', () {
      final game = _game(
        units: {
          UnitType.scout: Unit(type: UnitType.scout, count: 20),
        },
      );
      final before = game.resources[ResourceType.algae]!.amount;
      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.beforeAmount, before);
      expect(change.afterAmount, before - 20);
      expect(change.produced, -20);
    });

    test('negative net production floors at zero', () {
      final game = _game(
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae, amount: 10, maxStorage: 5000,
          ),
        },
        units: {
          UnitType.scout: Unit(type: UnitType.scout, count: 20),
        },
      );
      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.afterAmount, 0);
    });

    test('recruitment flag tracks correctly', () {
      final game = _game(
        recruitedUnitTypes: [UnitType.scout, UnitType.harpoonist],
      );
      final result = TurnResolver().resolve(game);
      expect(result.hadRecruitedUnits, isTrue);
      expect(game.recruitedUnitTypes, isEmpty);
    });

    test('turn numbers track correctly', () {
      final game = _game(turn: 5);
      final result = TurnResolver().resolve(game);
      expect(result.previousTurn, 5);
      expect(result.newTurn, 6);
    });

    test('multiple resources with mixed production and maintenance', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1),
          BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 1),
        },
        units: {
          UnitType.scout: Unit(type: UnitType.scout, count: 10),
        },
      );
      final result = TurnResolver().resolve(game);
      final algae = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      final coral = result.changes.firstWhere((c) => c.type == ResourceType.coral);
      expect(algae.produced, 40); // 50 production - 10 maintenance
      expect(coral.produced, 40); // 40 production - 0 maintenance
    });
  });
}
