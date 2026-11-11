extends TestCase
## test/domain/faction/faction_exploration_test.dart: where a faction's
## scouts look first, and the brain exploring towards the middle.

var _corner := GridPosition.new(3, 3)


static func _bias(base: GridPosition, x: int, y: int) -> float:
	return FactionExploration.bias(base, 32, 32, GridPosition.new(x, y))


func test_the_faction_brain_explores_towards_the_middle_of_the_map() -> void:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2)
	var player: Player = game.players[game.factions()[0].id()]
	player.units_on_level(1)[UnitType.Value.SCOUT].count = 1
	var turn := ScriptSamples.turn(game, player)

	ExploreMoves.explore(turn, 1, 1, func(p: GridPosition) -> float:
		return FactionExploration.for_turn(turn, p))

	assert_eq(player.pending_explorations.size(), 1)
	var target := player.pending_explorations[0].target
	var w: int = game.levels[1].width
	var away := func(p: GridPosition) -> float:
		var c := DartMath.quotient(w - 1, 2)
		return maxf(absf(p.x - c), absf(p.y - c))
	var target_away: float = away.call(target)
	var base_away: float = away.call(GridPosition.new(player.base_x, player.base_y))
	assert_true(target_away < base_away)


func test_a_cell_nearer_the_centre_is_worth_more_than_one_on_the_border() -> void:
	assert_true(_bias(_corner, 9, 9) > _bias(_corner, 29, 3))
	assert_true(_bias(_corner, 9, 9) > _bias(_corner, 3, 0))


func test_a_diagonal_step_beats_a_straight_one_of_the_same_reach() -> void:
	assert_true(_bias(_corner, 9, 9) > _bias(_corner, 9, 3))
	assert_true(_bias(_corner, 9, 9) > _bias(_corner, 3, 9))


func test_away_from_the_centre_is_worth_less_than_staying() -> void:
	assert_true(_bias(_corner, 0, 0) < _bias(_corner, 3, 3))


func test_it_is_symmetric_the_opposite_corner_reasons_the_same_way() -> void:
	var far := GridPosition.new(28, 28)
	assert_almost_eq(_bias(far, 22, 22), _bias(_corner, 9, 9), 0.001)


func test_a_base_at_the_centre_still_prefers_diagonals_to_straight_lines() -> void:
	var centre := GridPosition.new(16, 16)
	assert_true(_bias(centre, 20, 20) > _bias(centre, 20, 16))
