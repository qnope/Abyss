extends TestCase
## test/domain/action/descend_action_test.dart: going down through a Faille
## the player holds.

const SCOUT := UnitType.Value.SCOUT


func _action(scouts: int, from_level := 1) -> DescendAction:
	var selected: Dictionary[UnitType.Value, int] = {}
	if scouts > 0:
		selected[SCOUT] = scouts
	return DescendAction.new(5, 5, from_level, selected)


func _reason(game: Game, action: DescendAction) -> Variant:
	var result := action.validate(game, game.human_player())
	assert_false(result.is_success)
	return result.reason


func test_descend_action_validate_succeeds_with_valid_conditions() -> void:
	var game := MoveSamples.descend_game()
	assert_true(_action(3).validate(game, game.human_player()).is_success)


func test_descend_action_validate_fails_when_map_is_null() -> void:
	assert_eq(_reason(MoveSamples.descend_game(), _action(1, 99)), ActionFailure.Value.MAP_NOT_GENERATED)


func test_descend_action_validate_fails_when_cell_has_no_transition_base() -> void:
	var game := MoveSamples.descend_game("test", 1, 10, CellContentType.Value.EMPTY)
	assert_eq(_reason(game, _action(1)), ActionFailure.Value.NO_TRANSITION_BASE_HERE)


func test_descend_action_validate_fails_when_base_not_captured_by_player() -> void:
	assert_eq(_reason(MoveSamples.descend_game(null), _action(1)), ActionFailure.Value.BASE_NOT_CAPTURED)


func test_descend_action_validate_fails_when_required_building_missing() -> void:
	var game := MoveSamples.descend_game("test", 0)
	assert_eq(_reason(game, _action(1)), ActionFailure.Value.REQUIRED_BUILDING_MISSING)


func test_descend_action_validate_fails_with_insufficient_units() -> void:
	assert_eq(_reason(MoveSamples.descend_game(), _action(100)), ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_descend_action_validate_fails_with_no_units_selected() -> void:
	assert_eq(_reason(MoveSamples.descend_game(), _action(0)), ActionFailure.Value.NO_UNIT_SELECTED)


func test_descend_action_execute_generates_level_2_and_transfers_units() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	var result := _action(3).execute(game, player)
	assert_true(result.is_success)
	var descended: DescendResult = result
	assert_eq(descended.target_level, 2)
	assert_true(game.levels.has(2))
	assert_eq(player.units_on_level(1)[SCOUT].count, 7)
	assert_eq(player.units_on_level(2)[SCOUT].count, 3)


func test_descend_action_execute_initial_reveal_area_is_centered_on_transition_position() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	_action(1).execute(game, player)
	var revealed := player.revealed_cells_set_on_level(2)
	# Reveal should be centered on (5,5): the transition position
	assert_true(revealed.has(Vector2i(5, 5)))
	for pos: Vector2i in revealed:
		assert_true(absi(pos.x - 5) <= 2 and absi(pos.y - 5) <= 2, str(pos))


func test_descend_action_execute_does_not_regenerate_level_if_already_exists() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	_action(2).execute(game, player)
	var seed_ := game.levels[2].map_seed
	_action(2).execute(game, player)
	assert_eq(game.levels[2].map_seed, seed_)
	assert_eq(player.units_on_level(2)[SCOUT].count, 4)


## Not in the Dart file: a capsule leads the posts down, a degraded module
## stops a descent, and the description names the level left.
func test_a_post_needs_the_capsule_and_a_degraded_module_refuses() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	game.levels[1].cell_at(5, 5).transition_base.type = TransitionBaseType.Value.CHEMINEE
	assert_eq(_reason(game, _action(1)), ActionFailure.Value.REQUIRED_BUILDING_MISSING)
	player.buildings[BuildingType.Value.PRESSURE_CAPSULE].level = 1
	assert_true(_action(1).validate(game, player).is_success)
	game.levels[1].cell_at(5, 5).transition_base.type = TransitionBaseType.Value.FAILLE
	player.buildings[BuildingType.Value.HEADQUARTERS] = Building.new(BuildingType.Value.HEADQUARTERS, 1)
	assert_eq(_reason(game, _action(1)), ActionFailure.Value.REQUIRED_BUILDING_DEGRADED)
	assert_eq([_action(1).type(), _action(1).description()], [ActionType.Value.DESCEND, "Descente niveau 1"])
