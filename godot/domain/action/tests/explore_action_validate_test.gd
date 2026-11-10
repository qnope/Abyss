extends TestCase
## test/domain/action/explore_action_validate_test.dart: which cells a scout
## may explore.


func _validate(x: int, y: int, game := ActionSamples.explore_game()) -> ActionResult:
	return ExploreAction.new(x, y).validate(game, game.human_player())


func test_explore_action_validate_succeeds_with_scouts_and_eligible_revealed_cell() -> void:
	# (2,2) is revealed and not the base (3,3)
	assert_true(_validate(2, 2).is_success)


func test_explore_action_validate_succeeds_with_unrevealed_cell_adjacent_to_revealed() -> void:
	# (2,1) is unrevealed (Chebyshev dist 2), but neighbor (2,2) is revealed
	assert_true(_validate(2, 1).is_success)


func test_explore_action_validate_fails_with_no_map() -> void:
	var game := ActionSamples.explore_game()
	game.levels = {}
	var result := _validate(2, 2, game)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.MAP_NOT_GENERATED)


func test_explore_action_validate_fails_with_0_scouts() -> void:
	var result := _validate(2, 2, ActionSamples.explore_game(0))
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NO_SCOUT_AVAILABLE)


func test_explore_action_validate_fails_with_ineligible_cell() -> void:
	# (0,0) is unrevealed (dist 3) and all neighbors are also unrevealed
	var result := _validate(0, 0)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.CELL_NOT_ELIGIBLE)


func test_explore_action_validate_fails_on_base_cell() -> void:
	var result := _validate(3, 3)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.CELL_NOT_ELIGIBLE)
