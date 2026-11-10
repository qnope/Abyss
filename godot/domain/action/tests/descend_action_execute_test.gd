extends TestCase
## test/domain/action/descend_action_execute_test.dart: what a descent
## builds and moves.

const SCOUT := UnitType.Value.SCOUT


func _descend(game: Game, scouts: int) -> ActionResult:
	return DescendAction.new(5, 5, 1, {SCOUT: scouts}).execute(game, game.human_player())


func test_descend_action_execute_generates_target_level_when_absent() -> void:
	var game := MoveSamples.descend_game()
	assert_true(_descend(game, 2).is_success)
	assert_not_null(game.levels.get(2))


func test_descend_action_execute_transfers_units_from_source_to_target() -> void:
	var game := MoveSamples.descend_game()
	_descend(game, 3)
	assert_eq(game.human_player().units_on_level(1)[SCOUT].count, 7)
	assert_eq(game.human_player().units_on_level(2)[SCOUT].count, 3)


func test_descend_action_execute_returns_descend_result_with_target_level() -> void:
	var result := _descend(MoveSamples.descend_game(), 1)
	assert_true(result is DescendResult)
	var descended: DescendResult = result
	assert_eq(descended.target_level, 2)
	assert_eq(descended.units_sent, {SCOUT: 1})


func test_descend_action_execute_initializes_revealed_cells_on_target_level() -> void:
	var game := MoveSamples.descend_game()
	_descend(game, 1)
	assert_true(game.human_player().revealed_cells_per_level.has(2))
	assert_false(game.human_player().revealed_cells_on_level(2).is_empty())


func test_descend_action_execute_does_not_regenerate_map_on_second_descent() -> void:
	var game := MoveSamples.descend_game()
	_descend(game, 1)
	var seed_ := game.levels[2].map_seed
	_descend(game, 1)
	assert_eq(game.levels[2].map_seed, seed_)


## Not in the Dart file: a seeded descent draws the seed of the new level
## from its generator, and a level that exists already only opens the fog
## and the stocks of a player who never came.
func test_a_seeded_descent_draws_the_seed_and_arrives_on_an_existing_level() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	DescendAction.new(5, 5, 1, {SCOUT: 1}, DartRandom.new(9)).execute(game, player)
	assert_eq(game.levels[2].map_seed, DartRandom.new(9).next_int(0x7FFFFFFF))
	player.units_per_level.erase(2)
	player.revealed_cells_per_level.erase(2)
	var map := game.levels[2]
	assert_true(_descend(game, 1).is_success)
	assert_true(game.levels[2] == map)
	assert_eq(player.unit_counts_on_level(2), {SCOUT: 1})
	assert_eq(player.units_on_level(2).size(), UnitType.Value.size())
	assert_eq(player.revealed_cells_on_level(2).size(), 25)


## Not in the Dart file: a refused descent moves nothing, and a type chosen
## at 0 is skipped.
func test_a_refused_descent_moves_nothing_and_empty_types_are_skipped() -> void:
	var game := MoveSamples.descend_game()
	var player := game.human_player()
	assert_eq(_descend(game, 11).reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_eq([game.levels.size(), Unit.count_in(player.units_on_level(1), SCOUT)], [1, 10])
	var selected: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 0, SCOUT: 2}
	assert_true(DescendAction.new(5, 5, 1, selected).execute(game, player).is_success)
	assert_eq(player.unit_counts_on_level(2), {SCOUT: 2})
