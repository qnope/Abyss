extends TestCase
## test/domain/action/explore_action_test.dart: exploring on level 1 and on
## the levels below.

const SCOUT := UnitType.Value.SCOUT


func _player(level: int, scouts := 5) -> Player:
	var units: Dictionary[int, Dictionary] = {level: ActionSamples.scouts_only(scouts)}
	var revealed: Dictionary[int, Array] = {level: [GridPosition.new(3, 3)] as Array[GridPosition]}
	return Player.new("Test", "p1", 5, 5, null, null, null, units, [], [], revealed)


func _game(player: Player, levels: Array[int]) -> Game:
	var game := Game.single_player(player)
	for level: int in levels:
		game.levels[level] = MapSamples.plain_map(10, 10, 42)
	return game


func _validate(player: Player, levels: Array[int], level := 1, x := 3, y := 4) -> ActionResult:
	return ExploreAction.new(x, y, level).validate(_game(player, levels), player)


func test_explore_action_level_1_succeeds_with_scouts_on_level_1() -> void:
	assert_true(_validate(_player(1), [1]).is_success)


func test_explore_action_level_1_decrements_scouts_on_level_1() -> void:
	var player := _player(1)
	ExploreAction.new(3, 4).execute(_game(player, [1]), player)
	assert_eq(player.units_on_level(1)[SCOUT].count, 4)


func test_explore_action_level_1_fails_without_map_for_level() -> void:
	assert_false(_validate(_player(1), [], 1, 3, 3).is_success)


func test_explore_action_level_1_fails_without_scouts() -> void:
	assert_false(_validate(_player(1, 0), [1]).is_success)


func test_explore_action_level_2_succeeds_with_scouts_on_level_2() -> void:
	assert_true(_validate(_player(2), [2], 2).is_success)


func test_explore_action_level_2_decrements_scouts_on_level_2() -> void:
	var player := _player(2)
	ExploreAction.new(3, 4, 2).execute(_game(player, [2]), player)
	assert_eq(player.units_on_level(2)[SCOUT].count, 4)


func test_explore_action_level_2_adds_exploration_order_with_correct_level() -> void:
	var player := _player(2)
	ExploreAction.new(3, 4, 2).execute(_game(player, [2]), player)
	assert_eq(player.pending_explorations.size(), 1)
	assert_eq(player.pending_explorations[0].level, 2)


func test_explore_action_level_2_fails_when_map_missing_for_level_2() -> void:
	assert_false(_validate(_player(2), [1], 2, 3, 3).is_success)


func test_explore_action_level_2_fails_without_scouts_on_level_2() -> void:
	assert_false(_validate(_player(2, 0), [2], 2).is_success)
