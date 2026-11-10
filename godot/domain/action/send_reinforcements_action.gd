class_name SendReinforcementsAction
extends Action
## lib/domain/action/send_reinforcements_action.dart: sends units through a
## post the player holds to the level below, already reached; they arrive at
## its centre at the end of the turn.

var transition_x: int
var transition_y: int
var from_level: int
var selected_units: Dictionary[UnitType.Value, int]
## An int once executed, else null.
var _target_level: Variant = null
var _total_sent := 0


func _init(
	transition_x_: int, transition_y_: int, from_level_: int,
	selected_units_: Dictionary[UnitType.Value, int],
) -> void:
	transition_x = transition_x_
	transition_y = transition_y_
	from_level = from_level_
	selected_units = selected_units_


func type() -> ActionType.Value:
	return ActionType.Value.SEND_REINFORCEMENTS


func description() -> String:
	return "Envoyer des renforts"


func validate(game: Game, player: Player) -> ActionResult:
	var map: GameMap = game.levels.get(from_level)
	if map == null:
		return ActionResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	var cell := map.cell_at(transition_x, transition_y)
	if cell.content != CellContentType.Value.TRANSITION_BASE:
		return ActionResult.failure(ActionFailure.Value.NO_TRANSITION_BASE_HERE)
	var base := cell.transition_base
	if base == null or base.captured_by != player.id:
		return ActionResult.failure(ActionFailure.Value.BASE_NOT_CAPTURED)
	if game.levels.get(base.target_level()) == null:
		return ActionResult.failure(ActionFailure.Value.TARGET_LEVEL_NOT_EXPLORED)
	return _validate_units(player)


func _validate_units(player: Player) -> ActionResult:
	var total := 0
	for type_: UnitType.Value in selected_units:
		var count: int = selected_units[type_]
		if count <= 0:
			continue
		if count > Unit.count_in(player.units_on_level(from_level), type_):
			return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
		total += count
	if total <= 0:
		return ActionResult.failure(ActionFailure.Value.NO_UNIT_SELECTED)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var base := game.levels[from_level].cell_at(transition_x, transition_y).transition_base
	var target_level := base.target_level()
	var target_map: GameMap = game.levels[target_level]
	var arrival_point := GridPosition.new(
		DartMath.trunc_div(target_map.width, 2), DartMath.trunc_div(target_map.height, 2)
	)
	var units: Dictionary[UnitType.Value, int] = {}
	var total := 0
	for type_: UnitType.Value in selected_units:
		var count: int = selected_units[type_]
		if count <= 0:
			continue
		player.units_on_level(from_level)[type_].count -= count
		units[type_] = count
		total += count
	_target_level = target_level
	_total_sent = total
	player.pending_reinforcements.append(
		ReinforcementOrder.new(from_level, target_level, units, game.turn, arrival_point)
	)
	return ActionResult.success()


func make_history_entry(_game: Game, _player: Player, result: ActionResult, turn: int) -> HistoryEntry:
	if not result.is_success or _target_level == null:
		return null
	var target_level: int = _target_level
	return ReinforcementEntry.new(turn, target_level, _total_sent)
