class_name RecruitUnitAction
extends Action
## lib/domain/action/recruit_unit_action.dart: recruits `quantity` units of
## one type at the barracks, once a type a turn; they arrive at the base.

## The level of the map where recruits arrive, at the base.
const ARRIVAL_LEVEL := 1

var unit_type: UnitType.Value
var quantity: int


func _init(unit_type_: UnitType.Value, quantity_: int) -> void:
	unit_type = unit_type_
	quantity = quantity_


func type() -> ActionType.Value:
	return ActionType.Value.RECRUIT_UNIT


func description() -> String:
	return "Recruter %d UnitType.%s" % [quantity, DartEnum.name_of(UnitType.Value, unit_type)]


func validate(_game: Game, player: Player) -> ActionResult:
	var barracks_level := Building.level_in(player.buildings, BuildingType.Value.BARRACKS)
	if not UnitCostCalculator.new().is_unlocked(unit_type, barracks_level):
		return ActionResult.failure(ActionFailure.Value.UNIT_LOCKED)
	if player.recruited_unit_types.has(unit_type):
		return ActionResult.failure(ActionFailure.Value.RECRUITMENT_ALREADY_DONE)
	if quantity <= 0:
		return ActionResult.failure(ActionFailure.Value.INVALID_QUANTITY)
	var costs := _costs(player)
	for resource: ResourceType.Value in costs:
		var total_cost := costs[resource] * quantity
		if player.resources[resource].amount < total_cost:
			return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var costs := _costs(player)
	for resource: ResourceType.Value in costs:
		player.resources[resource].amount -= costs[resource] * quantity
	player.units_on_level(ARRIVAL_LEVEL)[unit_type].count += quantity
	player.recruited_unit_types.append(unit_type)
	return ActionResult.success()


func make_history_entry(_game: Game, _player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
	return RecruitEntry.new(turn, unit_type, quantity)


func noise_made(_player: Player) -> int:
	return NoiseRules.PER_RECRUIT * quantity


func _costs(player: Player) -> Dictionary[ResourceType.Value, int]:
	return UnitCostCalculator.new().recruitment_cost(
		unit_type, player.is_degraded(BuildingType.Value.BARRACKS)
	)
