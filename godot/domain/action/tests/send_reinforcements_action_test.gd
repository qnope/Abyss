extends TestCase
## test/domain/action/send_reinforcements_action_test.dart: units sent down
## to the level below, arriving at the end of the turn.

const SCOUT := UnitType.Value.SCOUT


## `createReinforcementAction`: 3 scouts unless `units` says otherwise.
func _action(units: Variant = null) -> SendReinforcementsAction:
	var selected: Dictionary[UnitType.Value, int] = {SCOUT: 3}
	if units != null:
		var given: Dictionary = units
		selected.assign(given)
	return SendReinforcementsAction.new(2, 2, 1, selected)


func _reason(game: Game, action := _action()) -> Variant:
	var result := action.validate(game, game.human_player())
	assert_false(result.is_success)
	return result.reason


func test_send_reinforcements_action_validate_succeeds_with_valid_conditions() -> void:
	var game := MoveSamples.reinforcement_game()
	assert_true(_action().validate(game, game.human_player()).is_success)


func test_send_reinforcements_action_validate_fails_when_map_is_missing() -> void:
	var game := MoveSamples.reinforcement_game()
	game.levels = {}
	assert_eq(_reason(game), ActionFailure.Value.MAP_NOT_GENERATED)


func test_send_reinforcements_action_validate_fails_when_cell_has_no_transition_base() -> void:
	var game := MoveSamples.reinforcement_game()
	game.levels[1] = MoveSamples.reinforcement_map()
	assert_eq(_reason(game), ActionFailure.Value.NO_TRANSITION_BASE_HERE)


func test_send_reinforcements_action_validate_fails_when_base_not_captured_by_player() -> void:
	assert_eq(_reason(MoveSamples.reinforcement_game(5, "other")), ActionFailure.Value.BASE_NOT_CAPTURED)


func test_send_reinforcements_action_validate_fails_when_target_level_not_generated() -> void:
	assert_eq(_reason(MoveSamples.reinforcement_game(5, "p1", false)), ActionFailure.Value.TARGET_LEVEL_NOT_EXPLORED)


func test_send_reinforcements_action_validate_fails_when_no_units_selected() -> void:
	assert_eq(_reason(MoveSamples.reinforcement_game(), _action({})), ActionFailure.Value.NO_UNIT_SELECTED)


func test_send_reinforcements_action_validate_fails_with_insufficient_units() -> void:
	assert_eq(_reason(MoveSamples.reinforcement_game(2)), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_send_reinforcements_action_execute_subtracts_units_from_source_level() -> void:
	var game := MoveSamples.reinforcement_game()
	_action().execute(game, game.human_player())
	assert_eq(game.human_player().units_on_level(1)[SCOUT].count, 2)


func test_send_reinforcements_action_execute_creates_pending_reinforcement_order() -> void:
	var game := MoveSamples.reinforcement_game()
	var player := game.human_player()
	_action().execute(game, player)
	assert_eq(player.pending_reinforcements.size(), 1)
	var order := player.pending_reinforcements[0]
	assert_eq([order.from_level, order.to_level, order.units, order.depart_turn], [1, 2, {SCOUT: 3}, 1])
	assert_eq([order.arrival_point.x, order.arrival_point.y], [2, 2])


func test_send_reinforcements_action_execute_returns_failure_on_invalid_input() -> void:
	var game := MoveSamples.reinforcement_game(0)
	assert_false(_action().execute(game, game.human_player()).is_success)


## Not in the Dart file: the selected types of none are left out of the
## order, and the description.
func test_an_empty_type_is_left_out_of_the_order() -> void:
	var game := MoveSamples.reinforcement_game()
	var action := _action({SCOUT: 2, UnitType.Value.HARPOONIST: 0})
	action.execute(game, game.human_player())
	assert_eq(game.human_player().pending_reinforcements[0].units, {SCOUT: 2})
	assert_eq([action.type(), action.description()], [ActionType.Value.SEND_REINFORCEMENTS, "Envoyer des renforts"])
