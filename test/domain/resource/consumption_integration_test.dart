import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

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
    // Energy: prod=18, cons=21 => net -3/turn
    // Algae: prod=50, cons=10 (scouts) => net +40/turn
    final game = _game(
      buildings: {
        BuildingType.headquarters: _b(BuildingType.headquarters, 1),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 1),
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 1),
        BuildingType.barracks: _b(BuildingType.barracks, 5),
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

    // Turn 21: stock=0, available=18 < consumption=21 => deactivation
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);
    expect(
      result.deactivatedBuildings,
      contains(BuildingType.algaeFarm),
    );
    // Deactivated buildings produce nothing
    expect(game.resources[ResourceType.energy]!.amount, 14);
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
    // SolarPanel lvl 2 produces 54, total consumption = 54
    // HQ(18)+SolarPanel(2)+Barracks(18)+AlgaeFarm(10)+OreExtractor(6)
    final game = _game(
      buildings: {
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 2),
        BuildingType.headquarters: _b(BuildingType.headquarters, 6),
        BuildingType.barracks: _b(BuildingType.barracks, 6),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 5),
        BuildingType.oreExtractor: _b(BuildingType.oreExtractor, 2),
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
        BuildingType.headquarters: _b(BuildingType.headquarters, 3),
        BuildingType.algaeFarm: _b(BuildingType.algaeFarm, 1),
        BuildingType.solarPanel: _b(BuildingType.solarPanel, 1),
        BuildingType.oreExtractor: _b(BuildingType.oreExtractor, 2),
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

    // Consumption=18 equals production+stock=18 => no deactivation
    var result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);

    // Add barracks: consumption=21 > available=18 => deactivation
    game.buildings[BuildingType.barracks] =
        _b(BuildingType.barracks, 1);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);

    // Upgrade solar panel lvl 3: prod=114 >> consumption=23
    game.buildings[BuildingType.solarPanel] =
        _b(BuildingType.solarPanel, 3);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);
  });
}
