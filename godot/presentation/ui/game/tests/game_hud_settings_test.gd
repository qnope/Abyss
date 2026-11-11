extends GameHudCase
## The settings opened from the game screen, and the way out they give
## (game_screen_settings_test.dart).


func test_the_gear_opens_the_settings_on_the_modals() -> void:
	_show()
	press(_hud.turn_bar.settings_button)
	var dialog := current_modal() as SettingsDialog
	assert_not_null(dialog)
	assert_eq(dialog.title(), "Paramètres")
	assert_not_null(find_text("Partie en cours", dialog))


func test_cancel_closes_them_and_leaves_the_game_alone() -> void:
	_show()
	var acted := []
	_actions.acted.connect(acted.append)
	_hud.open_settings()
	press("Annuler")
	assert_null(current_modal())
	assert_eq(_quits, 0)
	assert_eq(acted, [])


func test_save_and_quit_asks_to_leave_the_game() -> void:
	_show()
	_hud.open_settings()
	press("Sauvegarder et quitter")
	assert_eq(_quits, 1)
	assert_null(current_modal())


func test_dismissing_them_leaves_nothing() -> void:
	_show()
	_hud.open_settings()
	modals().close_top()
	assert_eq(_quits, 0)


func test_a_language_picked_is_told_and_checked_the_next_time() -> void:
	_show()
	_hud.open_settings()
	press("English")
	assert_eq(_languages, [LanguageChoice.Value.ENGLISH] as Array[LanguageChoice.Value])
	assert_eq(_hud.language, LanguageChoice.Value.ENGLISH)
	use_language("en")
	press("Cancel")
	_hud.open_settings()
	assert_true((current_modal() as SettingsDialog).picker.row(LanguageChoice.Value.ENGLISH).check.visible)


func test_the_guide_switches_are_changes_of_the_game_through_the_actions() -> void:
	_show()
	var acted := []
	_actions.acted.connect(acted.append)
	_hud.open_settings()
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	var was := state.tips_enabled
	press((current_modal() as SettingsDialog).guide.tips_switch.switch)
	assert_eq(state.tips_enabled, not was)
	assert_eq(acted, [null])


func test_the_story_is_told_again_over_the_settings() -> void:
	_show()
	_hud.open_settings()
	press("L'histoire du jeu")
	assert_true(current_modal() is OpeningStoryModal)
	assert_eq(modals().depth(), 2)
	press("Passer")
	assert_true(current_modal() is SettingsDialog)


func test_a_resource_opens_its_detail_on_the_same_modals() -> void:
	_show()
	press(_hud.resource_bar.items[ResourceType.Value.ORE])
	assert_true(current_modal() is ResourceDetailSheet)


func test_the_history_opens_its_sheet_when_the_settings_end() -> void:
	_game.human_player().history_entries.append(BuildingEntry.new(1, BuildingType.Value.ALGAE_FARM, 2))
	_show()
	_hud.open_settings()
	press("Voir l'historique")
	var sheet := current_modal() as HistorySheet
	assert_not_null(sheet)
	assert_eq(sheet.cards.size(), 1)
	assert_eq(modals().depth(), 1, "the settings are gone")
	assert_eq(_quits, 0)


func test_the_export_opens_its_dialog_when_the_settings_end() -> void:
	_show()
	_hud.open_settings()
	press("Exporter la partie")
	var dialog := current_modal() as ReplayExportDialog
	assert_not_null(dialog)
	assert_true(dialog.available)
