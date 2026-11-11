extends TestCase
## test/domain/action/collect_treasure_action_level_test.dart: searching
## ruins on the levels below.


func _deep_game(level: int) -> Game:
	var player := ActionSamples.collect_player()
	player.revealed_cells_per_level[level] = [GridPosition.new(1, 1)] as Array[GridPosition]
	var levels: Dictionary[int, GameMap] = {
		1: ActionSamples.collect_map(CellContentType.Value.EMPTY),
		level: ActionSamples.collect_map(CellContentType.Value.RUINS),
	}
	return Game.new(player.id, {player.id: player}, 1, null, levels)


func test_collect_treasure_action_on_deeper_levels_collects_ruins_on_level() -> void:
	for level: int in [2, 3]:
		var game := _deep_game(level)
		var result := CollectTreasureAction.new(1, 1, level, DartRandom.new(1)).execute(game, game.human_player())
		assert_true(result.is_success)
		assert_eq(game.levels[level].cell_at(1, 1).collected_by, game.human_player().id)
		assert_null(game.levels[1].cell_at(1, 1).collected_by)


func test_collect_treasure_action_on_deeper_levels_ruin_pearls_stay_within_the_level_times_the_multiplier() -> void:
	for level: int in [2, 3]:
		var seen := {}
		for seed_: int in 200:
			var game := _deep_game(level)
			var action := CollectTreasureAction.new(1, 1, level, DartRandom.new(seed_))
			var result: CollectTreasureResult = action.execute(game, game.human_player())
			seen[result.deltas[ResourceType.Value.PEARL]] = true
		var expected := {}
		for i: int in level + 2:
			expected[i * CollectTreasureAction.REWARD_MULTIPLIER] = true
		var found := seen.keys()
		found.sort()
		assert_eq(found, expected.keys(), "level %d" % level)


func test_collect_treasure_action_on_deeper_levels_fails_when_the_cell_is_not_revealed_on_that_level() -> void:
	var game := _deep_game(2)
	game.human_player().revealed_cells_per_level[2] = [] as Array[GridPosition]
	assert_false(CollectTreasureAction.new(1, 1, 2).validate(game, game.human_player()).is_success)
