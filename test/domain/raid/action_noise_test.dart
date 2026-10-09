import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'raid_test_helper.dart';

void main() {
  test('recruiting makes one noise per unit', () {
    final player = raidPlayer();
    player.buildings[BuildingType.barracks] =
        Building(type: BuildingType.barracks, level: 1);
    final game = Game.singlePlayer(player);
    ActionExecutor().execute(
      RecruitUnitAction(unitType: UnitType.harpoonist, quantity: 4),
      game,
      player,
    );
    expect(player.raidState.noise, 4);
  });

  test('upgrading makes as much noise as the level reached', () {
    final player = raidPlayer();
    player.buildings[BuildingType.headquarters] =
        Building(type: BuildingType.headquarters, level: 2);
    final game = Game.singlePlayer(player);
    ActionExecutor().execute(
      UpgradeBuildingAction(buildingType: BuildingType.headquarters),
      game,
      player,
    );
    expect(player.raidState.noise, 3);
  });

  test('each kernel level makes the noise of its level', () {
    expect(NoiseRules.forUpgrade(BuildingType.volcanicKernel, 3), 3);
    expect(NoiseRules.forUpgrade(BuildingType.headquarters, 3), 3);
  });

  test('a failed action makes no noise', () {
    final player = raidPlayer();
    final game = Game.singlePlayer(player);
    ActionExecutor().execute(
      RecruitUnitAction(unitType: UnitType.harpoonist, quantity: 0),
      game,
      player,
    );
    expect(player.raidState.noise, 0);
  });
}
