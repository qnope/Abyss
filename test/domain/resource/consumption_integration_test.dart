import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
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
  final player = Player(
    name: 'Test',
    buildings: buildings,
    resources: resources,
    units: units,
  );
  return Game.singlePlayer(player);
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
        ...PlayerDefaults.units(),
        UnitType.scout: Unit(type: UnitType.scout, count: 10),
      },
    );
    final player = game.humanPlayer;

    // Turn 1: energy 60->57, algae 100->140
    var result = resolver.resolve(game);
    expect(player.resources[ResourceType.energy]!.amount, 57);
    expect(player.resources[ResourceType.algae]!.amount, 140);
    expect(result.deactivatedBuildings, isEmpty);

    // Turns 2-20: energy drains by 3 each turn
    for (var i = 0; i < 19; i++) {
      result = resolver.resolve(game);
      expect(result.deactivatedBuildings, isEmpty);
    }
    expect(player.resources[ResourceType.energy]!.amount, 0);
    expect(player.resources[ResourceType.algae]!.amount, 900);

    // Turn 21: stock=0, available=18 < consumption=21 => deactivation
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);
    expect(result.deactivatedBuildings, contains(BuildingType.algaeFarm));
    // Deactivated buildings produce nothing
    expect(player.resources[ResourceType.energy]!.amount, 14);
    expect(player.resources[ResourceType.algae]!.amount, 890);
  });

  test('no consumption with empty game', () {
    final game = _game();
    final player = game.humanPlayer;
    final energyBefore = player.resources[ResourceType.energy]!.amount;
    final algaeBefore = player.resources[ResourceType.algae]!.amount;

    final result = resolver.resolve(game);

    expect(result.deactivatedBuildings, isEmpty);
    expect(result.lostUnits, isEmpty);
    expect(result.changes, isEmpty);
    expect(player.resources[ResourceType.energy]!.amount, energyBefore);
    expect(player.resources[ResourceType.algae]!.amount, algaeBefore);
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
    final player = game.humanPlayer;
    final energyBefore = player.resources[ResourceType.energy]!.amount;
    final result = resolver.resolve(game);

    expect(result.deactivatedBuildings, isEmpty);
    expect(player.resources[ResourceType.energy]!.amount, energyBefore);
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
        ...PlayerDefaults.resources(),
        ResourceType.energy: Resource(
          type: ResourceType.energy,
          amount: 0,
          maxStorage: 1000,
        ),
      },
    );
    final player = game.humanPlayer;

    // Consumption=18 equals production+stock=18 => no deactivation
    var result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);

    // Add barracks: consumption=21 > available=18 => deactivation
    player.buildings[BuildingType.barracks] = _b(BuildingType.barracks, 1);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isNotEmpty);

    // Upgrade solar panel lvl 3: prod=114 >> consumption=23
    player.buildings[BuildingType.solarPanel] = _b(BuildingType.solarPanel, 3);
    result = resolver.resolve(game);
    expect(result.deactivatedBuildings, isEmpty);
  });
}
