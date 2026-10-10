import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_degradation.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:flutter_test/flutter_test.dart';

Map<BuildingType, Building> _base(int hq, Map<BuildingType, int> levels) => {
  BuildingType.headquarters: Building(
    type: BuildingType.headquarters,
    level: hq,
  ),
  for (final e in levels.entries) e.key: Building(type: e.key, level: e.value),
};

void main() {
  const calculator = BuildingCostCalculator();

  group('BuildingDegradation.isDegraded', () {
    // Each type at a level, with the HQ level it needs.
    final cases = <BuildingType, (int level, int needs)>{
      BuildingType.algaeFarm: (3, 4),
      BuildingType.coralMine: (2, 2),
      BuildingType.oreExtractor: (5, 10),
      BuildingType.solarPanel: (4, 6),
      BuildingType.laboratory: (3, 5),
      BuildingType.barracks: (2, 4),
      BuildingType.coralCitadel: (2, 5),
      BuildingType.descentModule: (1, 5),
      BuildingType.pressureCapsule: (1, 8),
      BuildingType.volcanicKernel: (7, 10),
    };

    for (final entry in cases.entries) {
      final type = entry.key;
      final (level, needs) = entry.value;

      test('$type level $level needs the QG at $needs', () {
        expect(
          calculator.prerequisites(type, level)[BuildingType.headquarters],
          needs,
        );
        final met = _base(needs, {type: level});
        final below = _base(needs - 1, {type: level});
        expect(BuildingDegradation.isDegraded(met, type), isFalse);
        expect(BuildingDegradation.isDegraded(below, type), isTrue);
        expect(BuildingDegradation.missingHeadquarters(below, type), needs);
        expect(BuildingDegradation.missingHeadquarters(met, type), isNull);
      });

      test('$type comes back to normal once the QG is raised again', () {
        final buildings = _base(needs - 1, {type: level});
        expect(BuildingDegradation.isDegraded(buildings, type), isTrue);
        buildings[BuildingType.headquarters]!.level = needs;
        expect(BuildingDegradation.isDegraded(buildings, type), isFalse);
      });
    }

    test('the levels are kept, only the state changes', () {
      final buildings = _base(1, {BuildingType.laboratory: 3});
      expect(
        BuildingDegradation.isDegraded(buildings, BuildingType.laboratory),
        isTrue,
      );
      expect(buildings[BuildingType.laboratory]!.level, 3);
    });

    test('an unbuilt building or the QG itself is never degraded', () {
      final buildings = _base(1, {BuildingType.barracks: 0});
      expect(
        BuildingDegradation.isDegraded(buildings, BuildingType.barracks),
        isFalse,
      );
      expect(
        BuildingDegradation.isDegraded(buildings, BuildingType.headquarters),
        isFalse,
      );
      expect(
        BuildingDegradation.isDegraded(buildings, BuildingType.coralMine),
        isFalse,
      );
    });

    test('a bare fixture without a built QG is not degraded', () {
      final buildings = _base(0, {BuildingType.barracks: 2});
      expect(
        BuildingDegradation.isDegraded(buildings, BuildingType.barracks),
        isFalse,
      );
      expect(
        BuildingDegradation.isDegraded({
          BuildingType.barracks: Building(
            type: BuildingType.barracks,
            level: 2,
          ),
        }, BuildingType.barracks),
        isFalse,
      );
    });

    test('the same rule on a player', () {
      final player = Player(
        name: 'P',
        buildings: _base(4, {BuildingType.barracks: 2}),
      );
      expect(player.isDegraded(BuildingType.barracks), isFalse);
      player.lowerHeadquarters(1);
      expect(player.isDegraded(BuildingType.barracks), isTrue);
    });
  });

  group('Player.lowerHeadquarters', () {
    Player player(int hq) => Player(name: 'P', buildings: _base(hq, {}));

    test('lowers the QG by the given levels', () {
      final p = player(6);
      expect(p.lowerHeadquarters(2), 4);
      expect(p.buildings[BuildingType.headquarters]!.level, 4);
    });

    test('never goes below level 1', () {
      final p = player(2);
      expect(p.lowerHeadquarters(5), 1);
      expect(p.buildings[BuildingType.headquarters]!.level, 1);
      expect(p.lowerHeadquarters(1), 1);
    });
  });
}
