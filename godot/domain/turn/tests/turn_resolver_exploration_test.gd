extends TestCase
## test/domain/turn/turn_resolver_exploration_test.dart: the explorations
## resolved at the end of a turn.


static func _game(game_map: GameMap = null, pending_explorations: Array[ExplorationOrder] = []) -> Game:
	var player := Player.new("Test", null, 5, 5, null, null, null, null, [], pending_explorations)
	player.tech_branches[TechBranch.Value.EXPLORER] = TechBranchState.new(TechBranch.Value.EXPLORER, false, 0)
	var game := Game.single_player(player)
	if game_map != null:
		game.levels = {1: game_map}
	return game


static func _orders() -> Array[ExplorationOrder]:
	return [ExplorationOrder.new(GridPosition.new(5, 5))]


func test_explorations_included_in_turn_result() -> void:
	var game := _game(MapSamples.plain_map(10, 10, 42), _orders())

	var result := TurnResolver.new().resolve(game)

	assert_eq(result.explorations.size(), 1)
	# Level 0 reveals a 3x3 square (9 cells) centered on the target.
	assert_eq(result.explorations[0].new_cells_revealed, 9)


func test_pending_explorations_cleared_after_turn() -> void:
	var game := _game(MapSamples.plain_map(10, 10, 42), _orders())

	TurnResolver.new().resolve(game)

	assert_true(game.human_player().pending_explorations.is_empty())


func test_no_explorations_when_list_is_empty() -> void:
	var game := _game(MapSamples.plain_map(10, 10, 42))

	var result := TurnResolver.new().resolve(game)

	assert_true(result.explorations.is_empty())


func test_no_explorations_when_map_is_null() -> void:
	var game := _game(null, _orders())

	var result := TurnResolver.new().resolve(game)

	assert_true(result.explorations.is_empty())
