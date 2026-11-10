extends TestCase
## test/domain/action/make_history_entry_test.dart, the groups
## 'UnlockBranchAction.makeHistoryEntry' and 'ResearchTechAction
## .makeHistoryEntry'.

const MILITARY := TechBranch.Value.MILITARY


func _player(military_unlocked: bool) -> Player:
	var player := ActionSamples.stocked(
		ActionSamples.amounts(500, 500, 500, 500, 50), {BuildingType.Value.LABORATORY: 1}
	)
	player.tech_branches = TechHelpers.tech_branches_with([TechBranchState.new(MILITARY, military_unlocked)])
	return player


func test_unlock_branch_action_make_history_entry_returns_research_entry_with_is_unlock_true() -> void:
	var player := _player(false)
	var game := ActionSamples.game_of(player)
	var action := UnlockBranchAction.new(MILITARY)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var research: ResearchEntry = action.make_history_entry(game, player, result, 5)
	assert_eq([research.turn, research.category], [5, HistoryEntryCategory.Value.RESEARCH])
	assert_eq([research.branch, research.is_unlock, research.new_level], [MILITARY, true, null])


func test_research_tech_action_make_history_entry_returns_research_entry_with_post_execute_research_level() -> void:
	var player := _player(true)
	var game := ActionSamples.game_of(player)
	var action := ResearchTechAction.new(MILITARY)
	var result := action.execute(game, player)
	assert_true(result.is_success)
	var research: ResearchEntry = action.make_history_entry(game, player, result, 7)
	assert_eq([research.turn, research.category], [7, HistoryEntryCategory.Value.RESEARCH])
	assert_eq([research.branch, research.is_unlock, research.new_level], [MILITARY, false, 1])
