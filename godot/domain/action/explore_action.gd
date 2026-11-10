class_name ExploreAction
extends Action
## lib/domain/action/explore_action.dart: sends a scout of `level` to an
## eligible cell; the exploration resolves at the end of the turn.

var target_x: int
var target_y: int
var level: int


func _init(target_x_: int, target_y_: int, level_ := 1) -> void:
	target_x = target_x_
	target_y = target_y_
	level = level_


func type() -> ActionType.Value:
	return ActionType.Value.EXPLORE


func description() -> String:
	return "Explorer (%d, %d)" % [target_x, target_y]


func validate(game: Game, player: Player) -> ActionResult:
	var map: GameMap = game.levels.get(level)
	if map == null:
		return ActionResult.failure(ActionFailure.Value.MAP_NOT_GENERATED)
	if player.event_state.is_active(RandomEventType.Value.STORM, game.turn):
		return ActionResult.failure(ActionFailure.Value.STORM_BLOCKS_EXPLORATION)
	if Unit.count_in(player.units_on_level(level), UnitType.Value.SCOUT) <= 0:
		return ActionResult.failure(ActionFailure.Value.NO_SCOUT_AVAILABLE)
	if not CellEligibilityChecker.is_eligible(map, player, target_x, target_y, level):
		return ActionResult.failure(ActionFailure.Value.CELL_NOT_ELIGIBLE)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	player.units_on_level(level)[UnitType.Value.SCOUT].count -= 1
	player.pending_explorations.append(ExplorationOrder.new(GridPosition.new(target_x, target_y), level))
	return ActionResult.success()


func make_history_entry(_game: Game, _player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
	return ExploreEntry.new(turn, target_x, target_y)


func noise_made(player: Player) -> int:
	return TechEffects.of(player).muffle(NoiseRules.PER_EXPLORATION)
