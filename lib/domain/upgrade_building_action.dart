import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'building_cost_calculator.dart';
import 'building_type.dart';
import 'game.dart';

class UpgradeBuildingAction extends Action {
  final BuildingType buildingType;

  UpgradeBuildingAction({required this.buildingType});

  @override
  ActionType get type => ActionType.upgradeBuilding;

  @override
  String get description => 'Ameliorer $buildingType';

  @override
  ActionResult validate(Game game) {
    final building = game.buildings[buildingType];
    if (building == null) {
      return ActionResult.failure('Batiment introuvable');
    }
    final check = BuildingCostCalculator().checkUpgrade(
      type: buildingType,
      currentLevel: building.level,
      resources: game.resources,
      allBuildings: game.buildings,
    );
    if (check.isMaxLevel) {
      return ActionResult.failure('Niveau maximum atteint');
    }
    if (!check.canUpgrade) {
      return ActionResult.failure('Ressources insuffisantes');
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;
    final costs = BuildingCostCalculator()
        .upgradeCost(buildingType, game.buildings[buildingType]!.level);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value;
    }
    game.buildings[buildingType]!.level++;
    return ActionResult.success();
  }
}
