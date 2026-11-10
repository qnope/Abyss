extends TestCase
## test/domain/action/make_history_entry_test.dart, the groups
## 'ExploreAction.makeHistoryEntry' and 'CollectTreasureAction
## .makeHistoryEntry'.


func test_explore_action_make_history_entry_returns_explore_entry_with_target_coordinates() -> void:
	var game := ActionSamples.explore_game()
	var player := game.human_player()
	var action := ExploreAction.new(4, 3)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var explore: ExploreEntry = action.make_history_entry(game, player, result, 11)
	assert_eq([explore.turn, explore.category], [11, HistoryEntryCategory.Value.EXPLORE])
	assert_eq([explore.target_x, explore.target_y], [4, 3])


func test_collect_treasure_action_make_history_entry_returns_collect_entry_with_gains_from_result() -> void:
	var game := ActionSamples.collect_game(CellContentType.Value.RESOURCE_BONUS)
	var player := game.human_player()
	var action := CollectTreasureAction.new(1, 1, 1, DartRandom.new(0))
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var collect: CollectEntry = action.make_history_entry(game, player, result, 13)
	assert_eq([collect.turn, collect.category], [13, HistoryEntryCategory.Value.COLLECT])
	assert_eq([collect.target_x, collect.target_y], [1, 1])
	assert_false(collect.gains.is_empty())
	assert_has(collect.gains.keys(), ResourceType.Value.ALGAE)
