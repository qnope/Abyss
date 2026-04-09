import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../building/building_cost_calculator.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';

class UpgradeBuildingAction extends Action {
  final BuildingType buildingType;

  UpgradeBuildingAction({required this.buildingType});

  @override
  ActionType get type => ActionType.upgradeBuilding;

  @override
  String get description => 'Ameliorer $buildingType';

  @override
  ActionResult validate(Game game, Player player) {
    final building = player.buildings[buildingType];
    if (building == null) {
      return ActionResult.failure('Batiment introuvable');
    }
    final check = BuildingCostCalculator().checkUpgrade(
      type: buildingType,
      currentLevel: building.level,
      resources: player.resources,
      allBuildings: player.buildings,
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
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final costs = BuildingCostCalculator()
        .upgradeCost(buildingType, player.buildings[buildingType]!.level);
    for (final entry in costs.entries) {
      player.resources[entry.key]!.amount -= entry.value;
    }
    player.buildings[buildingType]!.level++;
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
}
