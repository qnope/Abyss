extends TestCase
## test/domain/map/exploration_resolver_test.dart, its groups 'single player
## exploration' and 'multi-player exploration'; 'level 2 exploration' is in
## exploration_resolver_level_2_test.gd.


func _explorer(id: String, orders: Array[ExplorationOrder] = [], revealed: Dictionary[int, Array] = {}) -> Player:
	return Player.new(id, id, 5, 5, null, null, null, null, [], orders, revealed)


func _plain_map() -> GameMap:
	return MapSamples.plain_map(10, 10, 42)


func _order(x: int, y: int, level := 1) -> Array[ExplorationOrder]:
	return [ExplorationOrder.new(GridPosition.new(x, y), level)]


func test_single_player_exploration_reveals_expected_cells_on_the_player() -> void:
	var player := _explorer("solo", _order(3, 3))
	var game := Game.single_player(player)
	game.levels = {1: _plain_map()}
	var target := player.pending_explorations[0].target
	var results := ExplorationResolver.resolve(game)
	var expected := GridPosition.keys(RevealAreaCalculator.cells_to_reveal(3, 3, 3, 10, 10))
	for key: Vector2i in expected:
		assert_has(player.revealed_cells(), key)
	assert_eq(player.pending_explorations.size(), 0)
	assert_eq(results.size(), 1)
	assert_true(results[0].target == target)
	assert_eq(results[0].new_cells_revealed, expected.size())


func test_single_player_exploration_already_revealed_cells_are_not_recounted() -> void:
	var seeded: Array[GridPosition] = [GridPosition.new(3, 3)]
	var player := _explorer("solo", _order(3, 3), {1: seeded})
	var game := Game.single_player(player)
	game.levels = {1: _plain_map()}
	# Level 0 reveals a 3x3 area (9 cells), one of which is pre-seeded.
	assert_eq(ExplorationResolver.resolve(game)[0].new_cells_revealed, 8)


func test_single_player_exploration_boundary_exploration_near_edge_counts_only_in_bounds_cells() -> void:
	var player := _explorer("solo", _order(9, 0))
	var game := Game.single_player(player)
	game.levels = {1: _plain_map()}
	assert_eq(ExplorationResolver.resolve(game)[0].new_cells_revealed, 4)
	assert_eq(player.revealed_cells(), {
		Vector2i(8, 0): true, Vector2i(9, 0): true, Vector2i(8, 1): true, Vector2i(9, 1): true,
	})


func test_multi_player_exploration_players_only_reveal_their_own_cells() -> void:
	var alice := _explorer("alice", _order(2, 2))
	var bob := _explorer("bob", _order(7, 7))
	var game := GameSamples.game([alice, bob])
	game.levels = {1: _plain_map()}
	ExplorationResolver.resolve(game)
	assert_true(alice.revealed_cells().has(Vector2i(2, 2)))
	assert_false(alice.revealed_cells().has(Vector2i(7, 7)))
	assert_true(bob.revealed_cells().has(Vector2i(7, 7)))
	assert_false(bob.revealed_cells().has(Vector2i(2, 2)))
	assert_eq(alice.pending_explorations.size(), 0)
	assert_eq(bob.pending_explorations.size(), 0)


func test_multi_player_exploration_results_only_report_the_human_player_explorations() -> void:
	var bob := _explorer("bob", _order(7, 7))
	var game := GameSamples.game([_explorer("alice"), bob])
	game.levels = {1: _plain_map()}
	assert_eq(ExplorationResolver.resolve(game).size(), 0)
	assert_true(bob.revealed_cells().has(Vector2i(7, 7)))


func test_multi_player_exploration_player_without_pending_orders_is_untouched() -> void:
	var bob := _explorer("bob")
	var game := GameSamples.game([_explorer("alice", _order(2, 2)), bob])
	game.levels = {1: _plain_map()}
	ExplorationResolver.resolve(game)
	assert_eq(bob.revealed_cells().size(), 0)
	assert_eq(bob.pending_explorations.size(), 0)
