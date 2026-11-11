extends TestCase
## test/domain/script/strategies/explore_moves_test.dart: the frontier cells
## a script sends its scouts to.

const SCOUT := UnitType.Value.SCOUT


func _turn(scouts := 0) -> ScriptTurn:
	var game := GameFactory.new_single_player("p", 5)
	game.human_player().units_on_level(1)[SCOUT].count = scouts
	return ScriptSamples.turn(game)


func _none(_p: GridPosition) -> float:
	return 0.0


func _down_left(p: GridPosition) -> float:
	return -10.0 * (p.x + p.y)


func _targets(turn: ScriptTurn) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	for order: ExplorationOrder in turn.player.pending_explorations:
		targets.append(order.target.key())
	return targets


func test_sends_each_scout_to_a_different_frontier_cell() -> void:
	var turn := _turn(3)
	ExploreMoves.explore(turn, 1, 2, _none)

	var orders := turn.player.pending_explorations
	assert_eq(orders.size(), 2)
	assert_ne(orders[0].target.key(), orders[1].target.key())
	assert_eq(turn.player.units_on_level(1)[SCOUT].count, 1)
	var known := turn.player.revealed_cells_set_on_level(1)
	for order: ExplorationOrder in orders:
		assert_false(known.has(order.target.key()))


func test_the_bias_steers_the_scouts() -> void:
	var turn := _turn(1)
	ExploreMoves.explore(turn, 1, 1, _down_left)

	assert_eq(turn.player.pending_explorations.size(), 1)
	var target := turn.player.pending_explorations[0].target
	assert_true(target.x + target.y < turn.player.base_x + turn.player.base_y)


func test_picks_the_same_cells_as_the_previous_implementation() -> void:
	var turn := _turn(3)
	ExploreMoves.explore(turn, 1, 2, _none)
	assert_eq(_targets(turn), [Vector2i(8, 5), Vector2i(14, 5)] as Array[Vector2i])


func test_picks_the_same_biased_cells_as_the_previous_implementation() -> void:
	var turn := _turn(3)
	ExploreMoves.explore(turn, 1, 3, _down_left)
	assert_eq(_targets(turn), [Vector2i(8, 5), Vector2i(10, 5), Vector2i(8, 7)] as Array[Vector2i])


func test_does_nothing_without_scouts() -> void:
	var turn := _turn()
	ExploreMoves.explore(turn, 1, 2, _none)
	assert_true(turn.player.pending_explorations.is_empty())


func test_a_storm_keeps_the_scouts_home_without_a_failed_action() -> void:
	var turn := _turn(3)
	turn.game.turn = 12
	turn.player.event_state.activate(RandomEventType.Value.STORM, 13)
	var log_: Array[ScriptLogEntry] = []
	var stormy := ScriptSamples.turn(turn.game, null, 1, log_)

	ExploreMoves.explore(stormy, 1, 2, _none)

	assert_true(stormy.player.pending_explorations.is_empty())
	assert_eq(stormy.player.units_on_level(1)[SCOUT].count, 3)
	assert_true(log_.is_empty())


func test_revealed_where_only_looks_at_revealed_cells() -> void:
	var turn := _turn()
	var all := func(_c: MapCell) -> bool: return true
	var revealed := ExploreMoves.revealed_where(turn, 1, all)
	assert_eq(revealed.size(), turn.player.revealed_cells_on_level(1).size())
	assert_true(ExploreMoves.revealed_where(turn, 2, all).is_empty())


## Not in the Dart file: a level without a map, the whole map known, the
## treasures picked up, and a frontier with nothing new left to reveal.
func test_a_level_without_a_map_or_fully_known_and_the_treasures_picked_up() -> void:
	var turn := _turn(3)
	assert_false(ExploreMoves.fully_explored(turn, 4))
	assert_false(ExploreMoves.fully_explored(turn, 1))
	ExploreMoves.explore(turn, 4, 2, _none)
	assert_true(turn.player.pending_explorations.is_empty())
	var map := turn.game.levels[1]
	var treasure := GridPosition.new(0, 0)
	map.set_cell(0, 0, map.cell_at(0, 0).copy_with({"content": CellContentType.Value.RESOURCE_BONUS}))
	for y: int in map.height:
		for x: int in map.width:
			turn.player.add_revealed_cell(1, GridPosition.new(x, y))
	assert_true(ExploreMoves.fully_explored(turn, 1))
	ExploreMoves.explore(turn, 1, 2, _none)
	assert_true(turn.player.pending_explorations.is_empty(), "no frontier")
	ExploreMoves.collect_revealed(turn, 1)
	assert_eq(map.cell_at(treasure.x, treasure.y).collected_by, turn.player.id)
