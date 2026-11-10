extends TestCase
## test/domain/map/exploration_resolver_multi_test.dart: several orders, the
## cells already seen, what the revealed cells hold.


func _game(orders: Array[ExplorationOrder], revealed: Array[GridPosition] = [], contents: Dictionary[Vector2i, CellContentType.Value] = {}) -> Game:
	var map := MapSamples.plain_map(10, 10, 42)
	for at: Vector2i in contents:
		map.set_cell(at.x, at.y, MapCell.new(TerrainType.Value.PLAIN, contents[at]))
	var player := Player.new("Test", null, 5, 5, null, null, null, null, [], orders, {1: revealed})
	player.tech_branches[TechBranch.Value.EXPLORER] = TechBranchState.new(TechBranch.Value.EXPLORER, false, 0)
	var game := Game.single_player(player)
	game.levels = {1: map}
	return game


func _orders(targets: Array[Vector2i]) -> Array[ExplorationOrder]:
	var orders: Array[ExplorationOrder] = []
	for target: Vector2i in targets:
		orders.append(ExplorationOrder.new(GridPosition.of_key(target)))
	return orders


func test_multiple_explorations_two_orders_resolved_independently() -> void:
	var results := ExplorationResolver.resolve(_game(_orders([Vector2i(2, 2), Vector2i(7, 7)])))
	assert_eq(results.size(), 2)
	assert_eq(results[0].new_cells_revealed, 9)
	assert_eq(results[1].new_cells_revealed, 9)


func test_idempotency_re_revealing_already_revealed_cells_yields_zero_new() -> void:
	# Pre-reveal the full 3x3 square centered on target (3,3).
	var revealed: Array[GridPosition] = []
	for y: int in range(2, 5):
		for x: int in range(2, 5):
			revealed.append(GridPosition.new(x, y))
	var results := ExplorationResolver.resolve(_game(_orders([Vector2i(3, 3)]), revealed))
	assert_eq(results[0].new_cells_revealed, 0)


func test_notable_content_finds_notable_content_in_reveal_area() -> void:
	var contents: Dictionary[Vector2i, CellContentType.Value] = {Vector2i(5, 4): CellContentType.Value.RUINS}
	var results := ExplorationResolver.resolve(_game(_orders([Vector2i(5, 5)]), [], contents))
	assert_has(results[0].notable_content, CellContentType.Value.RUINS)
