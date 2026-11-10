extends TestCase
## test/domain/action/make_history_entry_test.dart, the group
## 'ExploreAction.makeHistoryEntry'; 'CollectTreasureAction
## .makeHistoryEntry' waits for CollectTreasureAction.


func test_explore_action_make_history_entry_returns_explore_entry_with_target_coordinates() -> void:
	var game := ActionSamples.explore_game()
	var player := game.human_player()
	var action := ExploreAction.new(4, 3)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var explore: ExploreEntry = action.make_history_entry(game, player, result, 11)
	assert_eq([explore.turn, explore.category], [11, HistoryEntryCategory.Value.EXPLORE])
	assert_eq([explore.target_x, explore.target_y], [4, 3])

