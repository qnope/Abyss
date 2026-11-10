extends TestCase
## test/domain/game/game_test.dart. Its check that `createdAt is set` never
## comes: the date is left out of the state (reference/README.md, "Fields
## left out").


func test_game_single_player_human_player_returns_the_provided_player() -> void:
	var p := Player.new("A", "a", 5, 5)
	var game := Game.single_player(p)
	assert_true(game.human_player() == p)
	assert_eq(game.human_player_id, "a")


func test_game_single_player_players_map_has_exactly_one_entry_keyed_by_player_id() -> void:
	var p := Player.new("A", "a", 5, 5)
	var game := Game.single_player(p)
	assert_eq(game.players.size(), 1)
	assert_true(game.players.has("a"))
	assert_true(game.players["a"] == p)


func test_game_single_player_turn_defaults_to_1_and_created_at_is_set() -> void:
	assert_eq(Game.single_player(Player.new("A", "a", 5, 5)).turn, 1)


func test_game_single_player_levels_is_empty_initially() -> void:
	var game := Game.single_player(Player.new("A", "a", 5, 5))
	assert_eq(game.levels.size(), 0)
	assert_null(game.map_for_level(1))
	assert_null(game.map_for_level(2))


func test_game_multi_player_container_constructing_with_two_players_exposes_both() -> void:
	var a := Player.new("Alice", "a", 5, 5)
	var b := Player.new("Bob", "b", 8, 8)
	var game := Game.new("b", {a.id: a, b.id: b})
	assert_eq(game.players.size(), 2)
	assert_true(game.human_player() == b)
	assert_true(game.players["a"] == a)


func test_game_multi_player_container_custom_turn_value_is_preserved() -> void:
	var p := Player.new("A", "a", 5, 5)
	assert_eq(Game.new(p.id, {p.id: p}, 12).turn, 12)


func test_game_is_volcanic_kernel_captured_by_returns_false_when_level_3_does_not_exist() -> void:
	assert_false(Game.single_player(_player()).is_volcanic_kernel_captured_by("p1"))


func test_game_is_volcanic_kernel_captured_by_returns_false_when_kernel_is_uncaptured() -> void:
	assert_false(_with_kernel(null).is_volcanic_kernel_captured_by("p1"))


func test_game_is_volcanic_kernel_captured_by_returns_true_when_kernel_is_captured_by_player_id() -> void:
	assert_true(_with_kernel("p1").is_volcanic_kernel_captured_by("p1"))


func test_game_is_volcanic_kernel_captured_by_returns_false_when_kernel_is_captured_by_another_player() -> void:
	assert_false(_with_kernel("other").is_volcanic_kernel_captured_by("p1"))


func _player() -> Player:
	return Player.new("P", "p1", 0, 0)


func _with_kernel(collected_by: Variant) -> Game:
	var player := _player()
	var cells: Array[MapCell] = [
		MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, collected_by),
	]
	return Game.new(player.id, {player.id: player}, 1, {3: GameMap.new(cells.size(), 1, cells, 0)})
