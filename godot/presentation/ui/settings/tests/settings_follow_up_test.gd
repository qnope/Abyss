extends UiTestCase
## game_screen_settings_actions.dart: the page each way out of the settings
## opens.

var _game: Game
var _follow_up := SettingsFollowUp.new()


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)


func test_the_history_is_the_sheet_of_the_human_player() -> void:
	_game.human_player().history_entries.append(BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2))
	var page := _follow_up.page(SettingsLinks.HISTORY, _game, modals())
	assert_true(page is HistorySheet)
	assert_eq((page as HistorySheet).cards.size(), 1)
	page.free()


func test_the_ranking_is_the_sheet_of_the_standings_of_the_game() -> void:
	var rivals := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2)
	var page := _follow_up.page(SettingsLinks.RANKING, rivals, modals())
	assert_true(page is FactionRankingSheet)
	assert_eq((page as FactionRankingSheet).tiles.size(), 3)
	page.free()


func test_the_export_is_the_dialog_of_the_game() -> void:
	var page := _follow_up.page(SettingsLinks.EXPORT, _game, modals())
	assert_true(page is ReplayExportDialog)
	assert_eq((page as ReplayExportDialog).game, _game)
	page.free()


func test_the_other_results_open_nothing() -> void:
	for result: Variant in [SettingsDialog.CANCEL, SettingsDialog.SAVE_AND_QUIT, null]:
		assert_null(_follow_up.page(result, _game, modals()))
