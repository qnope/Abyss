import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/resource_type.dart';

void main() {
  group('Game', () {
    test('creates game with player and default turn 1', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player);

      expect(game.player.name, 'Nemo');
      expect(game.turn, 1);
      expect(game.createdAt, isNotNull);
    });

    test('creates game with custom turn', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player, turn: 5);

      expect(game.turn, 5);
    });

    test('creates game with default 5 resources', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player);
      expect(game.resources.length, 5);
      expect(game.resources.containsKey(ResourceType.algae), isTrue);
      expect(game.resources.containsKey(ResourceType.coral), isTrue);
      expect(game.resources.containsKey(ResourceType.ore), isTrue);
      expect(game.resources.containsKey(ResourceType.energy), isTrue);
      expect(game.resources.containsKey(ResourceType.pearl), isTrue);
    });

    test('turn can be incremented', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player);
      game.turn++;
      expect(game.turn, 2);
    });

    test('creates with default buildings (7 buildings at level 0)', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player);
      expect(game.buildings.length, 7);
      expect(game.buildings[BuildingType.headquarters]!.type, BuildingType.headquarters);
      expect(game.buildings[BuildingType.headquarters]!.level, 0);
      expect(game.buildings[BuildingType.algaeFarm]!.level, 0);
      expect(game.buildings[BuildingType.coralMine]!.level, 0);
      expect(game.buildings[BuildingType.oreExtractor]!.level, 0);
      expect(game.buildings[BuildingType.solarPanel]!.level, 0);
      expect(game.buildings[BuildingType.laboratory]!.level, 0);
      expect(game.buildings[BuildingType.barracks]!.level, 0);
    });

    test('default buildings include all 4 production buildings at level 0', () {
      final buildings = Game.defaultBuildings();
      final productionTypes = [
        BuildingType.algaeFarm,
        BuildingType.coralMine,
        BuildingType.oreExtractor,
        BuildingType.solarPanel,
      ];
      for (final type in productionTypes) {
        expect(buildings.containsKey(type), isTrue);
        expect(buildings[type]!.level, 0);
      }
    });

    test('creates with custom buildings list', () {
      final player = Player(name: 'Nemo');
      final buildings = {
        BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 3),
      };
      final game = Game(player: player, buildings: buildings);
      expect(game.buildings.length, 1);
      expect(game.buildings[BuildingType.headquarters]!.level, 3);
    });
  });
}
