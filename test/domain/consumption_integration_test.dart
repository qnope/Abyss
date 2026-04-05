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
}) {
  return Game(
    player: Player(name: 'Test'),
    buildings: buildings ?? Game.defaultBuildings(),
    resources: resources ?? Game.defaultResources(),
    units: units,
  );
}

Building _b(BuildingType t, int lvl) => Building(type: t, level: lvl);

void main() {
  late TurnResolver resolver;
  setUp(() => resolver = TurnResolver());

  test('full consumption scenario over multiple turns', () {
    // Energy: prod=6, cons=9 => net -3/turn
    // Algae: prod=50, cons=10 (scouts) => net +40/turn
    final game = _game(
      buildings: {
        BuildingType.headquarters: _b(BuildingType.headquarters, 1),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 1),
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 1),
        BuildingType.barracks: _b(BuildingType.barracks, 1),
      },
      units: {
        ...Game.defaultUnits(),
        UnitType.scout: Unit(type: UnitType.scout, count: 10),
      },
    );

    // Turn 1: energy 60->57, algae 100->140
    var result = resolver.resolve(game);
    expect(game.resources[ResourceType.energy]!.amount, 57);
    expect(game.resources[ResourceType.algae]!.amount, 140);
    expect(result.deactivatedBuildings, isEmpty);

    // Turns 2-20: energy drains by 3 each turn
    for (var i = 0; i < 19; i++) {
      result = resolver.resolve(game);
      expect(result.deactivatedBuildings, isEmpty);
    }
    expect(game.resources[ResourceType.energy]!.amount, 0);
    expect(game.resources[ResourceType.algae]!.amount, 900);

    // Turn 21: stock=0, available=6 < consumption=9 => deactivation
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);
    expect(
      result.deactivatedBuildings,
      contains(BuildingType.algaeFarm),
    );
    // Deactivated buildings produce nothing
    expect(game.resources[ResourceType.energy]!.amount, 2);
    expect(game.resources[ResourceType.algae]!.amount, 890);
  });

  test('no consumption with empty game', () {
    final game = _game();
    final energyBefore = game.resources[ResourceType.energy]!.amount;
    final algaeBefore = game.resources[ResourceType.algae]!.amount;

    final result = resolver.resolve(game);

    expect(result.deactivatedBuildings, isEmpty);
    expect(result.lostUnits, isEmpty);
    expect(result.changes, isEmpty);
    expect(game.resources[ResourceType.energy]!.amount, energyBefore);
    expect(game.resources[ResourceType.algae]!.amount, algaeBefore);
  });

  test('consumption exactly equals production', () {
    // SolarPanel lvl 2 produces 18, total consumption = 18
    // HQ(9)+SolarPanel(2)+AlgaeFarm(2)+OreExtractor(3)+CoralMine(2)
    final game = _game(
      buildings: {
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 2),
        BuildingType.headquarters: _b(BuildingType.headquarters, 3),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 1),
        BuildingType.oreExtractor: _b(BuildingType.oreExtractor, 1),
        BuildingType.coralMine: _b(BuildingType.coralMine, 1),
      },
    );
    final energyBefore = game.resources[ResourceType.energy]!.amount;
    final result = resolver.resolve(game);

    expect(result.deactivatedBuildings, isEmpty);
    expect(game.resources[ResourceType.energy]!.amount, energyBefore);
  });

  test('deactivation restores next turn when conditions improve', () {
    final game = _game(
      buildings: {
        BuildingType.headquarters: _b(BuildingType.headquarters, 1),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 1),
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 1),
      },
      resources: {
        ...Game.defaultResources(),
        ResourceType.energy: Resource(
          type: ResourceType.energy,
          amount: 0,
          maxStorage: 1000,
        ),
      },
    );

    // Consumption=6 equals production+stock=6 => no deactivation
    var result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);

    // Add barracks: consumption=9 > available=6 => deactivation
    game.buildings[BuildingType.barracks] =
        _b(BuildingType.barracks, 1);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);

    // Upgrade solar panel lvl 3: prod=38 >> consumption=11
    game.buildings[BuildingType.solarPanel] =
        _b(BuildingType.solarPanel, 3);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);
  });
}
