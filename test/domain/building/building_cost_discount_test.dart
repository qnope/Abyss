import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_cost_calculator.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/building/upgrade_check.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tech_helpers.dart';

const _hq = BuildingType.headquarters;

Map<ResourceType, Resource> _stock(int coral, int ore) => {
  ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
  ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
};

void main() {
  const thrifty = BuildingCostCalculator(discountPercent: 15);

  group('Chantiers économes discount', () {
    test('no discount by default', () {
      expect(const BuildingCostCalculator().upgradeCost(_hq, 0),
          {ResourceType.coral: 60, ResourceType.ore: 40});
    });

    test('takes 15% off every resource, rounded down', () {
      expect(thrifty.upgradeCost(_hq, 0),
          {ResourceType.coral: 51, ResourceType.ore: 34});
      // 629 * 0.85 = 534.65 ; 419 * 0.85 = 356.15
      expect(thrifty.upgradeCost(_hq, 5),
          {ResourceType.coral: 534, ResourceType.ore: 356});
    });

    test('a maxed building stays without cost', () {
      expect(thrifty.upgradeCost(_hq, 10), isEmpty);
    });

    test('the check accepts the discounted price', () {
      UpgradeCheck check(BuildingCostCalculator c) => c.checkUpgrade(
            type: _hq,
            currentLevel: 0,
            resources: _stock(51, 34),
            allBuildings: const {},
          );
      expect(check(thrifty).canUpgrade, isTrue);
      expect(check(const BuildingCostCalculator()).missingResources,
          {ResourceType.coral: 9, ResourceType.ore: 6});
    });

    test('an upgrade by a player with the option pays less', () {
      final player = Player(
        id: 'p',
        name: 'Test',
        resources: _stock(100, 100),
        buildings: {_hq: Building(type: _hq, level: 0)},
        techBranches: techBranchesWith([
          researchedBranch(TechBranch.resources, 4,
              options: [TechOption.a, TechOption.b]),
        ]),
      );
      final game = Game(humanPlayerId: player.id, players: {player.id: player});
      final result =
          UpgradeBuildingAction(buildingType: _hq).execute(game, player);

      expect(result.isSuccess, isTrue);
      expect(player.resources[ResourceType.coral]!.amount, 49);
      expect(player.resources[ResourceType.ore]!.amount, 66);
    });
  });
}
