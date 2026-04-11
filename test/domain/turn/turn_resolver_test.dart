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

Player _player({
  String id = 'human',
  Map<BuildingType, int>? buildingLevels,
  Map<ResourceType, int>? resourceAmounts,
  Map<UnitType, int>? unitCounts,
}) {
  final p = Player(id: id, name: id, baseX: 5, baseY: 5);
  buildingLevels?.forEach((type, level) {
    p.buildings[type] = Building(type: type, level: level);
  });
  resourceAmounts?.forEach((type, amount) {
    p.resources[type]!.amount = amount;
  });
  unitCounts?.forEach((type, count) {
    p.unitsOnLevel(1)[type] = Unit(type: type, count: count);
  });
  return p;
}

Game _singleGame(Player p, {int turn = 1}) =>
    Game.singlePlayer(p)..turn = turn;

void main() {
  late TurnResolver resolver;
  setUp(() => resolver = TurnResolver());

  group('Production and turn tracking', () {
    test('single building produces and reports change', () {
      final p = _player(buildingLevels: {BuildingType.algaeFarm: 2});
      final before = p.resources[ResourceType.algae]!.amount;
      final result = resolver.resolve(_singleGame(p));
      expect(p.resources[ResourceType.algae]!.amount, before + 140);
      final c = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.produced, 140);
    });

    test('game.turn increments exactly once per resolve', () {
      final game = _singleGame(_player(), turn: 5);
      final result = resolver.resolve(game);
      expect(game.turn, 6);
      expect(result.previousTurn, 5);
      expect(result.newTurn, 6);
    });

    test('result reads from humanPlayer and clears recruitedUnitTypes', () {
      final p = _player();
      p.recruitedUnitTypes.addAll([UnitType.scout, UnitType.harpoonist]);
      final result = resolver.resolve(_singleGame(p));
      expect(result.hadRecruitedUnits, isTrue);
      expect(p.recruitedUnitTypes, isEmpty);
    });
  });

  group('Storage capping', () {
    test('production capped at maxStorage', () {
      final p = _player(buildingLevels: {BuildingType.algaeFarm: 1});
      p.resources[ResourceType.algae] =
          Resource(type: ResourceType.algae, amount: 498, maxStorage: 500);
      final result = resolver.resolve(_singleGame(p));
      final c = result.changes.firstWhere((c) => c.type == ResourceType.algae);
      expect(c.beforeAmount, 498);
      expect(c.afterAmount, 500);
      expect(c.wasCapped, isTrue);
    });
  });

  group('Energy consumption and deactivation', () {
    test('buildings consume energy from production', () {
      final p = _player(buildingLevels: {
        BuildingType.solarPanel: 2,
        BuildingType.algaeFarm: 1,
      });
      final before = p.resources[ResourceType.energy]!.amount;
      final result = resolver.resolve(_singleGame(p));
      expect(p.resources[ResourceType.energy]!.amount, before + 50);
      final c = result.changes.firstWhere((c) => c.type == ResourceType.energy);
      expect(c.produced, 54);
      expect(c.consumed, 4);
    });

    test('insufficient energy deactivates buildings', () {
      final p = _player(
        buildingLevels: {
          BuildingType.headquarters: 1,
          BuildingType.oreExtractor: 3,
        },
        resourceAmounts: {ResourceType.energy: 3},
      );
      final oreBefore = p.resources[ResourceType.ore]!.amount;
      final result = resolver.resolve(_singleGame(p));
      expect(result.deactivatedBuildings, contains(BuildingType.oreExtractor));
      expect(p.resources[ResourceType.ore]!.amount, oreBefore);
    });
  });

  group('Algae consumption and unit loss', () {
    test('unit losses applied when algae insufficient', () {
      final p = _player(
        resourceAmounts: {ResourceType.algae: 5},
        unitCounts: {UnitType.scout: 100},
      );
      final result = resolver.resolve(_singleGame(p));
      expect(result.lostUnits[UnitType.scout], greaterThan(0));
      expect(p.unitsOnLevel(1)[UnitType.scout]!.count, lessThan(100));
    });

    test('units on level 2 still consume algae', () {
      final p = _player(
        resourceAmounts: {ResourceType.algae: 0},
        unitCounts: {UnitType.scout: 10},
      );
      // Add 10 scouts on level 2
      p.unitsPerLevel[2] = {
        for (final t in UnitType.values) t: Unit(type: t),
      };
      p.unitsOnLevel(2)[UnitType.scout]!.count = 10;

      final result = resolver.resolve(_singleGame(p));
      // Both levels should lose units
      expect(result.lostUnits[UnitType.scout], greaterThan(0));
      expect(p.unitsOnLevel(1)[UnitType.scout]!.count, lessThan(10));
      expect(p.unitsOnLevel(2)[UnitType.scout]!.count, lessThan(10));
    });

    test('moving units to level 2 does not reduce algae consumption', () {
      // 20 scouts on level 1 only
      final pA = _player(
        resourceAmounts: {ResourceType.algae: 1000},
        unitCounts: {UnitType.scout: 20},
      );
      final gameA = _singleGame(pA);
      final resultA = resolver.resolve(gameA);
      final consumedA = resultA.changes
          .firstWhere((c) => c.type == ResourceType.algae)
          .consumed;

      // 10 on level 1, 10 on level 2
      final pB = _player(
        resourceAmounts: {ResourceType.algae: 1000},
        unitCounts: {UnitType.scout: 10},
      );
      pB.unitsPerLevel[2] = {
        for (final t in UnitType.values) t: Unit(type: t),
      };
      pB.unitsOnLevel(2)[UnitType.scout]!.count = 10;
      final gameB = _singleGame(pB);
      final resultB = resolver.resolve(gameB);
      final consumedB = resultB.changes
          .firstWhere((c) => c.type == ResourceType.algae)
          .consumed;

      expect(consumedA, consumedB);
    });
  });

  group('Multi-player isolation', () {
    test('resolve mutates each player independently', () {
      final alice = _player(
        id: 'alice',
        buildingLevels: {BuildingType.algaeFarm: 1},
      );
      final bob = _player(id: 'bob');
      final game = Game(
        humanPlayerId: alice.id,
        players: {alice.id: alice, bob.id: bob},
      );
      final bobAlgaeBefore = bob.resources[ResourceType.algae]!.amount;
      resolver.resolve(game);
      // Alice gains 50 algae from her farm; Bob's unchanged.
      expect(alice.resources[ResourceType.algae]!.amount, 150);
      expect(bob.resources[ResourceType.algae]!.amount, bobAlgaeBefore);
      // Turn incremented exactly once for the shared game.
      expect(game.turn, 2);
    });
  });
}
