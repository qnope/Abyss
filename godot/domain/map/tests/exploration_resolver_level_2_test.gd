extends TestCase
## test/domain/map/exploration_resolver_test.dart, its group 'level 2
## exploration'.


func _explorer(orders: Array[ExplorationOrder]) -> Player:
	return Player.new("solo", "solo", 5, 5, null, null, null, null, [], orders)


func _order(x: int, y: int, level: int) -> Array[ExplorationOrder]:
	return [ExplorationOrder.new(GridPosition.new(x, y), level)]


func _game(player: Player, levels: int) -> Game:
	var game := Game.single_player(player)
	for level: int in range(1, levels + 1):
		game.levels[level] = MapSamples.plain_map(10, 10, 42)
	return game


func test_level_2_exploration_reveals_cells_on_level_2_map() -> void:
	var player := _explorer(_order(4, 4, 2))
	var game := _game(player, 2)
	var results := ExplorationResolver.resolve(game)
	assert_true(player.revealed_cells_set_on_level(2).has(Vector2i(4, 4)))
	assert_true(results[0].new_cells_revealed > 0)
	assert_eq(player.pending_explorations.size(), 0)


func test_level_2_exploration_does_not_reveal_cells_on_level_1_when_exploring_level_2() -> void:
	var player := _explorer(_order(4, 4, 2))
	var game := _game(player, 2)
	ExplorationResolver.resolve(game)
	assert_eq(player.revealed_cells_set_on_level(1).size(), 0)
	assert_false(player.revealed_cells_set_on_level(2).is_empty())


func test_level_2_exploration_skips_order_when_target_level_map_is_missing() -> void:
	var player := _explorer(_order(4, 4, 2))
	var game := _game(player, 1)
	assert_eq(ExplorationResolver.resolve(game).size(), 0)
	assert_eq(player.pending_explorations.size(), 0)


func test_level_2_exploration_mixed_level_explorations_resolve_independently() -> void:
	var orders := _order(2, 2, 1)
	orders.append_array(_order(7, 7, 2))
	var player := _explorer(orders)
	var game := _game(player, 2)
	assert_eq(ExplorationResolver.resolve(game).size(), 2)
	assert_true(player.revealed_cells_set_on_level(1).has(Vector2i(2, 2)))
	assert_true(player.revealed_cells_set_on_level(2).has(Vector2i(7, 7)))
