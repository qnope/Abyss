import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('Player construction and ids', () {
    test('assigns a unique UUID when id is omitted', () {
      final a = Player(name: 'A');
      final b = Player(name: 'B');
      expect(a.id, isNotEmpty);
      expect(b.id, isNotEmpty);
      expect(a.id, isNot(equals(b.id)));
    });

    test('preserves an explicit id', () {
      final p = Player(id: 'fixed-id', name: 'A');
      expect(p.id, 'fixed-id');
    });

    test('default baseX/baseY are zero', () {
      final p = Player(name: 'A');
      expect(p.baseX, 0);
      expect(p.baseY, 0);
    });
  });

  group('Player defaults', () {
    test('default resources contain all 5 types with correct maxStorage', () {
      final p = Player(name: 'A');
      expect(p.resources.length, 5);
      expect(p.resources[ResourceType.algae]!.maxStorage, 5000);
      expect(p.resources[ResourceType.coral]!.maxStorage, 5000);
      expect(p.resources[ResourceType.ore]!.maxStorage, 5000);
      expect(p.resources[ResourceType.energy]!.maxStorage, 1000);
      expect(p.resources[ResourceType.pearl]!.maxStorage, 100);
    });

    test('default buildings contain 8 buildings at level 0', () {
      final p = Player(name: 'A');
      expect(p.buildings.length, 8);
      for (final type in [
        BuildingType.headquarters,
        BuildingType.algaeFarm,
        BuildingType.coralMine,
        BuildingType.oreExtractor,
        BuildingType.solarPanel,
        BuildingType.laboratory,
        BuildingType.barracks,
        BuildingType.coralCitadel,
      ]) {
        expect(p.buildings[type]!.level, 0);
      }
    });

    test('default tech branches are locked at level 0', () {
      final p = Player(name: 'A');
      expect(p.techBranches.length, 3);
      for (final b in TechBranch.values) {
        expect(p.techBranches[b]!.unlocked, isFalse);
        expect(p.techBranches[b]!.researchLevel, 0);
      }
    });

    test('default units contain all 6 unit types at count 0', () {
      final p = Player(name: 'A');
      expect(p.units.length, UnitType.values.length);
      for (final u in p.units.values) {
        expect(u.count, 0);
      }
    });

    test('default recruitedUnitTypes and pendingExplorations are empty', () {
      final p = Player(name: 'A');
      expect(p.recruitedUnitTypes, isEmpty);
      expect(p.pendingExplorations, isEmpty);
      expect(p.revealedCellsList, isEmpty);
    });
  });

  group('Player.withBase reveal seeding', () {
    test('revealedCells match RevealAreaCalculator output (5x5)', () {
      final p = Player.withBase(
        name: 'A',
        baseX: 10,
        baseY: 10,
        mapWidth: 20,
        mapHeight: 20,
      );
      final expected = RevealAreaCalculator.cellsToReveal(
        targetX: 10,
        targetY: 10,
        explorerLevel: 2,
        mapWidth: 20,
        mapHeight: 20,
      ).toSet();
      expect(p.revealedCells, expected);
      expect(p.revealedCells.length, 25);
      expect(p.baseX, 10);
      expect(p.baseY, 10);
      // Strict centering: 2 cells in each cardinal direction from the base.
      for (var d = 1; d <= 2; d++) {
        expect(p.revealedCells.contains(GridPosition(x: 10 - d, y: 10)), isTrue);
        expect(p.revealedCells.contains(GridPosition(x: 10 + d, y: 10)), isTrue);
        expect(p.revealedCells.contains(GridPosition(x: 10, y: 10 - d)), isTrue);
        expect(p.revealedCells.contains(GridPosition(x: 10, y: 10 + d)), isTrue);
      }
    });

    test('base near edge truncates naturally without shifting', () {
      final p = Player.withBase(
        name: 'A',
        baseX: 1,
        baseY: 1,
        mapWidth: 20,
        mapHeight: 20,
      );
      final expected = <GridPosition>{
        for (var y = 0; y <= 3; y++)
          for (var x = 0; x <= 3; x++) GridPosition(x: x, y: y),
      };
      expect(p.revealedCells, expected);
      expect(p.revealedCells.length, 16);
    });
  });

  group('Player isolation', () {
    test('two players mutate independently', () {
      final a = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final b = Player(id: 'b', name: 'B', baseX: 5, baseY: 5);
      a.resources[ResourceType.algae]!.amount = 999;
      expect(b.resources[ResourceType.algae]!.amount, isNot(999));
      expect(a.resources[ResourceType.algae]!.amount, 999);
    });
  });
}
