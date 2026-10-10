import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/consumption_calculator.dart';
import 'package:abyss/domain/resource/production_calculator.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_branch_state.dart';
import 'package:abyss/domain/tech/tech_effects.dart';
import 'package:abyss/domain/turn/turn_production.dart';
import 'package:flutter_test/flutter_test.dart';

Map<BuildingType, Building> _base(int hq, Map<BuildingType, int> levels) => {
  BuildingType.headquarters: Building(
    type: BuildingType.headquarters,
    level: hq,
  ),
  for (final e in levels.entries) e.key: Building(type: e.key, level: e.value),
};

int _made(Map<BuildingType, Building> b, ResourceType r) =>
    ProductionCalculator.fromBuildings(b)[r] ?? 0;

void main() {
  group('production buildings make half when degraded', () {
    // type, level, HQ needed, resource it makes.
    final cases = <(BuildingType, int, int, ResourceType)>[
      (BuildingType.algaeFarm, 3, 4, ResourceType.algae),
      (BuildingType.coralMine, 3, 4, ResourceType.coral),
      (BuildingType.oreExtractor, 3, 4, ResourceType.ore),
      (BuildingType.solarPanel, 3, 4, ResourceType.energy),
    ];
    for (final (type, level, needs, resource) in cases) {
      test('$type', () {
        final normal = _made(_base(needs, {type: level}), resource);
        final hqIncome = ProductionCalculator.headquartersIncome[resource] ?? 0;
        final degraded = _made(_base(needs - 1, {type: level}), resource);
        expect(normal - hqIncome, greaterThan(0));
        expect(degraded - hqIncome, (normal - hqIncome) ~/ 2);
      });
    }

    test('raising the QG restores the full production', () {
      final b = _base(3, {BuildingType.algaeFarm: 3});
      final low = _made(b, ResourceType.algae);
      b[BuildingType.headquarters]!.level = 4;
      expect(_made(b, ResourceType.algae), greaterThan(low));
    });

    test('the flat income of the QG is untouched', () {
      final b = _base(1, {BuildingType.coralMine: 3});
      final hq = ProductionCalculator.headquartersIncome[ResourceType.coral]!;
      expect(
        _made(b, ResourceType.coral) - hq,
        (_made(_base(4, {BuildingType.coralMine: 3}), ResourceType.coral) -
                hq) ~/
            2,
      );
    });

    test('a degraded building still burns its energy', () {
      final b = _base(1, {BuildingType.oreExtractor: 3});
      expect(ConsumptionCalculator.totalBuildingConsumption(b), 3 * 1 + 3 * 3);
    });

    test('TurnProduction sees the degraded buildings', () {
      Map<ResourceType, int> of(int hq) => TurnProduction.of(
        Player(name: 'P', buildings: _base(hq, {BuildingType.algaeFarm: 3})),
        turn: 1,
        difficulty: Difficulty.normal,
      );
      expect(of(1)[ResourceType.algae], lessThan(of(4)[ResourceType.algae]!));
    });
  });

  group('degraded laboratory halves the research effects', () {
    Map<TechBranch, TechBranchState> branches() => {
      TechBranch.military: TechBranchState(
        branch: TechBranch.military,
        unlocked: true,
        researchLevel: 3,
      ),
      TechBranch.resources: TechBranchState(
        branch: TechBranch.resources,
        unlocked: true,
        researchLevel: 3,
      ),
      TechBranch.explorer: TechBranchState(branch: TechBranch.explorer),
    };

    Player player(int hq) => Player(
      name: 'P',
      techBranches: branches(),
      buildings: _base(hq, {BuildingType.laboratory: 3}),
    );

    test('TechEffects.of halves the percentages', () {
      final full = TechEffects.of(player(5));
      final half = TechEffects.of(player(4));
      expect(full.atkPercent(), greaterThan(0));
      expect(half.atkPercent(), full.atkPercent() ~/ 2);
      expect(half.defPercent(), full.defPercent() ~/ 2);
      expect(
        half.productionPercent(ResourceType.ore),
        full.productionPercent(ResourceType.ore) ~/ 2,
      );
    });

    test('the production bonus of the research is halved too', () {
      final p = player(5);
      final full =
          ProductionCalculator.fromBuildings(
            p.buildings,
            techBranches: p.techBranches,
          )[ResourceType.coral]!;
      final q = player(4);
      final half =
          ProductionCalculator.fromBuildings(
            q.buildings,
            techBranches: q.techBranches,
          )[ResourceType.coral]!;
      expect(half, lessThan(full));
    });

    test('raising the QG restores it', () {
      final p = player(4);
      p.buildings[BuildingType.headquarters]!.level = 5;
      expect(
        TechEffects.of(p).atkPercent(),
        TechEffects.of(player(5)).atkPercent(),
      );
    });
  });
}
