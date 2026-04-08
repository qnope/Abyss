import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';

Game _game({
  Map<BuildingType, Building>? buildings,
  Map<ResourceType, Resource>? resources,
  Map<UnitType, Unit>? units,
  List<UnitType>? recruitedUnitTypes,
  int turn = 1,
}) {
  final r = PlayerDefaults.resources();
  if (resources != null) r.addAll(resources);
  return Game.singlePlayer(Player(
    name: 'Test',
    buildings: buildings,
    resources: r,
    units: units,
    recruitedUnitTypes: recruitedUnitTypes,
  ))..turn = turn;
}

Map<ResourceType, int> _netProduction(Game game) {
  final h = game.humanPlayer;
  final prod = ProductionCalculator.fromBuildings(
    h.buildings, techBranches: h.techBranches,
  );
  final eCons = ConsumptionCalculator.totalBuildingConsumption(h.buildings);
  final aCons = ConsumptionCalculator.totalUnitConsumption(h.units);
  final net = <ResourceType, int>{...prod};
  net[ResourceType.energy] = (net[ResourceType.energy] ?? 0) - eCons;
  net[ResourceType.algae] = (net[ResourceType.algae] ?? 0) - aCons;
  return net;
}

void main() {
  group('Turn flow data consistency', () {
    test('confirmation prediction matches resolver result', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 2),
        },
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 10)},
      );
      final net = _netProduction(game);
      final algae = game.humanPlayer.resources[ResourceType.algae]!;
      final predicted = (algae.amount + (net[ResourceType.algae] ?? 0))
          .clamp(0, algae.maxStorage);
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
          ResourceType.algae: Resource(
            type: ResourceType.algae, amount: 4900, maxStorage: 5000,
          ),
        },
      );
      final net = _netProduction(game);
      final algae = game.humanPlayer.resources[ResourceType.algae]!;
      final cap = algae.amount + (net[ResourceType.algae] ?? 0) > algae.maxStorage;
      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.wasCapped, cap);
      expect(change.afterAmount, algae.maxStorage);
    });

    test('consumption deducted correctly through full flow', () {
      final game = _game(
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 20)},
      );
      final before = game.humanPlayer.resources[ResourceType.algae]!.amount;
      final result = TurnResolver().resolve(game);
      final change = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(change.beforeAmount, before);
      expect(change.afterAmount, before - 20);
      expect(change.produced, 0);
      expect(change.consumed, 20);
    });

    test('negative net production floors at zero', () {
      final game = _game(
        resources: {
          ResourceType.algae: Resource(
            type: ResourceType.algae, amount: 10, maxStorage: 5000,
          ),
        },
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 20)},
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
      expect(game.humanPlayer.recruitedUnitTypes, isEmpty);
    });

    test('turn numbers track correctly', () {
      final game = _game(turn: 5);
      final result = TurnResolver().resolve(game);
      expect(result.previousTurn, 5);
      expect(result.newTurn, 6);
    });

    test('multiple resources with mixed production and consumption', () {
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1),
          BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 1),
        },
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 10)},
      );
      final result = TurnResolver().resolve(game);
      final algae = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      final coral = result.changes.firstWhere((c) => c.type == ResourceType.coral);
      expect(algae.produced, 50);
      expect(algae.consumed, 10);
      expect(coral.produced, 40);
    });
  });
}
