import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_cost_calculator.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../raid/noise_rules.dart';
import '../tech/tech_effects.dart';

class UpgradeBuildingAction extends Action {
  final BuildingType buildingType;

  UpgradeBuildingAction({required this.buildingType});

  static BuildingCostCalculator _calculator(Player player) =>
      BuildingCostCalculator(
        discountPercent:
            TechEffects.of(player).upgradeDiscountPercent);

  @override
  ActionType get type => ActionType.upgradeBuilding;

  @override
  String get description => 'Ameliorer $buildingType';

  @override
  ActionResult validate(Game game, Player player) {
    final building = player.buildings[buildingType];
    if (building == null) {
      return ActionResult.failure(ActionFailure.buildingNotFound);
    }
    final check = _calculator(player).checkUpgrade(
      type: buildingType,
      currentLevel: building.level,
      resources: player.resources,
      allBuildings: player.buildings,
      capturedBaseTypes: game.capturedBaseTypesOf(player.id),
      isVolcanicKernelCaptured:
          game.isVolcanicKernelCapturedBy(player.id),
    );
    final int hqLevel =
        player.buildings[BuildingType.headquarters]?.level ?? 0;
    if (player.worksite.freeBuildSites(hqLevel) <= 0) {
      return ActionResult.failure(ActionFailure.worksitesBusy);
    }
    if (check.isMaxLevel) {
      return ActionResult.failure(ActionFailure.maxLevelReached);
    }
    if (!check.canUpgrade) {
      return ActionResult.failure(ActionFailure.notEnoughResources);
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final costs = _calculator(player)
        .upgradeCost(buildingType, player.buildings[buildingType]!.level);
    for (final entry in costs.entries) {
      player.resources[entry.key]!.amount -= entry.value;
    }
    player.buildings[buildingType]!.level++;
    player.worksite.upgrades++;
    return ActionResult.success();
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    return BuildingEntry(
      turn: turn,
      buildingType: buildingType,
      newLevel: player.buildings[buildingType]!.level,
    );
  }

  @override
  int noiseMade(Player player) =>
      NoiseRules.forUpgrade(
          buildingType, player.buildings[buildingType]!.level);
}
