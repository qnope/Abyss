extends TestCase
## test/domain/action/attack_transition_base_action_test.dart: whether an
## assault on the guardians of a post may start. AttackTransitionBaseAction
## waits for the leviathan module; its `validate` is
## AttackTransitionBaseValidator.check with its own fields, which these
## tests call.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST
const ARMY: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, HARPOONIST: 5}


func _validate(game: Game, units: Dictionary[UnitType.Value, int] = ARMY) -> ActionResult:
	return AttackTransitionBaseValidator.check(game, game.human_player(), 1, 1, 1, units)


func test_validate_fails_when_map_is_null() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 10})
	game.levels.clear()
	var result := _validate(game)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)


func test_validate_fails_when_cell_is_not_a_transition_base() -> void:
	var game := SiegeSamples.attack_game(
		{ADMIRAL: 1, HARPOONIST: 10}, TransitionBaseType.Value.FAILLE, null, 1, 0, CellContentType.Value.EMPTY
	)
	var result := _validate(game)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NO_TRANSITION_BASE_HERE)


func test_validate_fails_when_base_is_already_captured() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 10}, TransitionBaseType.Value.FAILLE, "someone")
	var result := _validate(game)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.BASE_ALREADY_CAPTURED)


func test_validate_succeeds_without_descent_module_not_required_for_attack() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 10}, TransitionBaseType.Value.FAILLE, null, 0)
	assert_true(_validate(game).is_success)


func test_validate_fails_without_abyss_admiral() -> void:
	var game := SiegeSamples.attack_game({HARPOONIST: 10})
	var result := _validate(game, {HARPOONIST: 5})
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.ADMIRAL_REQUIRED)


func test_validate_fails_when_units_exceed_stock() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 2})
	var result := _validate(game, {ADMIRAL: 1, HARPOONIST: 10})
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)


func test_validate_succeeds_on_valid_scenario() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 10})
	assert_true(_validate(game).is_success)


## Not in the Dart file: a post cell that lost its post, an army of none
## of a type, and the failure the results give.
func test_validate_fails_on_a_post_cell_without_its_post() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 10})
	var map: GameMap = game.levels[1]
	map.set_cell(1, 1, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE))
	assert_eq(_validate(game).reason, ActionFailure.Value.BASE_NOT_FOUND)
	map.set_cell(1, 1, MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.TRANSITION_BASE, null, null,
		TransitionBase.new(TransitionBaseType.Value.CHEMINEE, "Cheminée")))
	assert_true(_validate(game, {ADMIRAL: 1, HARPOONIST: 0, UnitType.Value.SCOUT: -1}).is_success)
	var failed := AttackTransitionBaseResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_eq([failed.victory, failed.captured, failed.fight, failed.sent, failed.dead], [false, false, null, {}, {}])
