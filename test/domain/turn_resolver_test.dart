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
      final algaeBefore = game.resources[ResourceType.algae]!.amount;
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.algae]!.amount, algaeBefore + 140);
      // algaeFarm lvl 2 consumes 4 energy, so energy change also appears
      expect(result.changes.length, 2);
      final algaeChange = result.changes.firstWhere(
        (c) => c.type == ResourceType.algae,
      );
      expect(algaeChange.produced, 140);
    });
    test('multiple buildings produce correctly', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1),
        BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 2),
      });
      resolver.resolve(game);
      expect(game.resources[ResourceType.algae]!.amount, 150);
      expect(game.resources[ResourceType.coral]!.amount, 180);
      // 2 + 4 = 6 energy consumed from stock (60 -> 54)
      expect(game.resources[ResourceType.energy]!.amount, 54);
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
    test('units consume algae separately from production', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 10)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 50);
      expect(c.consumed, 10);
      expect(c.afterAmount, 140);
    });
    test('consumption exceeding production floors at zero', () {
      final game = _game(
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 100)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 0);
      expect(c.consumed, 100);
      expect(c.afterAmount, 0);
    });
    test('production and consumption shown separately', () {
      final game = _game(
        buildings: {BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 1)},
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 5)},
      );
      final c = resolver.resolve(game).changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 50);
      expect(c.consumed, 5);
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

    test('changes contains resources with production or consumption', () {
      final game = _game(buildings: {
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 1,
        ),
      });
      final result = resolver.resolve(game);
      // algae (produced) + energy (consumed by building)
      expect(result.changes.length, 2);
      final types = result.changes.map((c) => c.type).toSet();
      expect(types, contains(ResourceType.algae));
      expect(types, contains(ResourceType.energy));
    });
  });

  group('Recruitment reset', () {
    test('recruitedUnitTypes is cleared after resolve', () {
      final game = _game();
      game.recruitedUnitTypes.addAll([UnitType.scout, UnitType.harpoonist]);
      resolver.resolve(game);
      expect(game.recruitedUnitTypes, isEmpty);
    });

    test('empty recruitedUnitTypes stays empty after resolve', () {
      final game = _game();
      resolver.resolve(game);
      expect(game.recruitedUnitTypes, isEmpty);
    });
  });

  group('Energy consumption', () {
    test('buildings consume energy from production', () {
      // solarPanel lvl 2: produces 54 energy, consumes 2
      // algaeFarm lvl 1: consumes 2 energy
      // total consumption = 4, net energy = 54 - 4 = 50
      final game = _game(buildings: {
        BuildingType.solarPanel: Building(
          type: BuildingType.solarPanel,
          level: 2,
        ),
        BuildingType.algaeFarm: Building(
          type: BuildingType.algaeFarm,
          level: 1,
        ),
      });
      final energyBefore = game.resources[ResourceType.energy]!.amount;
      final result = resolver.resolve(game);

      expect(
        game.resources[ResourceType.energy]!.amount,
        energyBefore + 50,
      );
      final energyChange = result.changes.firstWhere(
        (c) => c.type == ResourceType.energy,
      );
      expect(energyChange.produced, 54);
      expect(energyChange.consumed, 4);
    });

    test('energy deducted from stock when production insufficient', () {
      // HQ lvl 1: consumes 3, no solar panel
      final game = _game(buildings: {
        BuildingType.headquarters: Building(
          type: BuildingType.headquarters,
          level: 1,
        ),
      });
      final result = resolver.resolve(game);

      expect(game.resources[ResourceType.energy]!.amount, 57);
      final energyChange = result.changes.firstWhere(
        (c) => c.type == ResourceType.energy,
      );
      expect(energyChange.consumed, 3);
      expect(energyChange.produced, 0);
    });

    test('building deactivation when energy insufficient', () {
      // Many buildings, no solar panel, low energy stock
      final game = _game(
        buildings: {
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 1,
          ),
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
          BuildingType.oreExtractor: Building(
            type: BuildingType.oreExtractor,
            level: 3,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.energy: Resource(
            type: ResourceType.energy,
            amount: 5,
            maxStorage: 1000,
          ),
        },
      );
      // HQ=3, algaeFarm=2, oreExtractor=9 => total=14, available=5
      final result = resolver.resolve(game);
      expect(result.deactivatedBuildings, isNotEmpty);
    });

    test('deactivated buildings produce nothing', () {
      // oreExtractor lvl 3 should get deactivated => no ore production
      final game = _game(
        buildings: {
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 1,
          ),
          BuildingType.oreExtractor: Building(
            type: BuildingType.oreExtractor,
            level: 3,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.energy: Resource(
            type: ResourceType.energy,
            amount: 3,
            maxStorage: 1000,
          ),
        },
      );
      // HQ=3, oreExtractor=9 => total=12, available=3
      // oreExtractor deactivated first
      final oreBefore = game.resources[ResourceType.ore]!.amount;
      final result = resolver.resolve(game);

      expect(
        result.deactivatedBuildings,
        contains(BuildingType.oreExtractor),
      );
      expect(game.resources[ResourceType.ore]!.amount, oreBefore);
    });
  });

  group('Algae consumption', () {
    test('units consume algae from production', () {
      // algaeFarm lvl 1: 50 algae, 10 scouts: 10 algae
      // net = 50 - 10 = 40
      final game = _game(
        buildings: {
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
        },
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 10),
        },
      );
      final algaeBefore = game.resources[ResourceType.algae]!.amount;
      resolver.resolve(game);
      expect(game.resources[ResourceType.algae]!.amount, algaeBefore + 40);
    });

    test('algae deducted from stock when production insufficient', () {
      // No farm, 5 scouts: 5 algae consumption
      final game = _game(
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 5),
        },
      );
      // algae stock=100, consumption=5, net=-5 => 95
      resolver.resolve(game);
      expect(game.resources[ResourceType.algae]!.amount, 95);
    });

    test('unit losses when algae insufficient', () {
      // Large army, no farm, low algae stock
      final game = _game(
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 5,
            maxStorage: 5000,
          ),
        },
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 100),
        },
      );
      // 100 scouts = 100 algae consumption, available=5
      final result = resolver.resolve(game);
      expect(result.lostUnits, isNotEmpty);
      expect(result.lostUnits[UnitType.scout], greaterThan(0));
    });

    test('unit losses applied to game state', () {
      final game = _game(
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 5,
            maxStorage: 5000,
          ),
        },
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 100),
        },
      );
      resolver.resolve(game);
      expect(game.units[UnitType.scout]!.count, lessThan(100));
    });

    test('proportional losses across types', () {
      final game = _game(
        resources: {
          ...Game.defaultResources(),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 0,
            maxStorage: 5000,
          ),
        },
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 50),
          UnitType.harpoonist: Unit(type: UnitType.harpoonist, count: 50),
        },
      );
      // total consumption: 50*1 + 50*2 = 150, available=0
      // loss ratio = 1.0, all units lost
      final result = resolver.resolve(game);
      expect(result.lostUnits[UnitType.scout], 50);
      expect(result.lostUnits[UnitType.harpoonist], 50);
    });
  });

  group('Combined consumption', () {
    test('full scenario: production, consumption, deactivation, loss', () {
      final game = _game(
        buildings: {
          BuildingType.solarPanel: Building(
            type: BuildingType.solarPanel,
            level: 1,
          ),
          BuildingType.algaeFarm: Building(
            type: BuildingType.algaeFarm,
            level: 1,
          ),
          BuildingType.headquarters: Building(
            type: BuildingType.headquarters,
            level: 1,
          ),
        },
        resources: {
          ...Game.defaultResources(),
          ResourceType.energy: Resource(
            type: ResourceType.energy,
            amount: 20,
            maxStorage: 1000,
          ),
          ResourceType.algae: Resource(
            type: ResourceType.algae,
            amount: 10,
            maxStorage: 5000,
          ),
        },
        units: {
          ...Game.defaultUnits(),
          UnitType.scout: Unit(type: UnitType.scout, count: 5),
        },
      );
      // solarPanel lvl 1: produces 18 energy, consumes 1
      // algaeFarm lvl 1: consumes 2 energy
      // HQ lvl 1: consumes 3 energy
      // total energy consumption=6, production=18, stock=20 => available=38
      // No deactivation needed
      // algae production=50, scouts consume 5 algae
      // net algae = 50-5 = 45 => stock: 10+45=55
      final result = resolver.resolve(game);

      expect(result.deactivatedBuildings, isEmpty);
      expect(result.lostUnits, isEmpty);
      expect(game.resources[ResourceType.algae]!.amount, 55);
      // energy: 20 + 18 - 6 = 32
      expect(game.resources[ResourceType.energy]!.amount, 32);
    });

    test('no consumption when no buildings and no units', () {
      final game = _game();
      final result = resolver.resolve(game);

      expect(result.changes, isEmpty);
      expect(result.deactivatedBuildings, isEmpty);
      expect(result.lostUnits, isEmpty);
    });
  });
}
