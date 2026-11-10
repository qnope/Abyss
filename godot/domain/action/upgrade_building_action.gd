class_name UpgradeBuildingAction
extends Action
## lib/domain/action/upgrade_building_action.dart: raises a building of the
## base by one level, paying its cost (less the research's discount) and
## taking a building site for the turn.

var building_type: BuildingType.Value


func _init(building_type_: BuildingType.Value) -> void:
	building_type = building_type_


static func _calculator(player: Player) -> BuildingCostCalculator:
	return BuildingCostCalculator.new(TechEffects.of(player).upgrade_discount_percent())


func type() -> ActionType.Value:
	return ActionType.Value.UPGRADE_BUILDING


func description() -> String:
	return "Ameliorer BuildingType.%s" % DartEnum.name_of(BuildingType.Value, building_type)


func validate(game: Game, player: Player) -> ActionResult:
	if not player.buildings.has(building_type):
		return ActionResult.failure(ActionFailure.Value.BUILDING_NOT_FOUND)
	var readiness := GameUpgradeReadiness.upgrade_readiness_of(game, player, building_type)
	var check := readiness.check
	if not readiness.site_free:
		return ActionResult.failure(ActionFailure.Value.WORKSITES_BUSY)
	if check.is_max_level:
		return ActionResult.failure(ActionFailure.Value.MAX_LEVEL_REACHED)
	if not check.can_upgrade:
		return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var building: Building = player.buildings[building_type]
	var costs := _calculator(player).upgrade_cost(building_type, building.level)
	for resource: ResourceType.Value in costs:
		player.resources[resource].amount -= costs[resource]
	building.level += 1
	player.worksite.upgrades += 1
	return ActionResult.success()


func make_history_entry(_game: Game, player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
	return BuildingEntry.new(turn, building_type, player.buildings[building_type].level)


func noise_made(player: Player) -> int:
	return NoiseRules.for_upgrade(building_type, player.buildings[building_type].level)
