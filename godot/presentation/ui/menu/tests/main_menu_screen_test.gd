extends UiTestCase
## test/presentation/screens/menu/main_menu_screen_test.dart and
## main_menu_language_test.dart: the title, the three entries, the shortcut to
## the latest game in progress, the settings in the corner.

var _resumed: Array[Game] = []
var _new_games := 0
var _loads := 0
var _languages: Array[LanguageChoice.Value] = []


func test_shows_the_title_and_the_menu() -> void:
	var menu := _menu([])
	assert_not_null(find_text("ABYSSES"))
	assert_not_null(find_text("LES PROFONDEURS VOUS ATTENDENT"))
	assert_not_null(find_text("NOUVELLE PARTIE"))
	assert_not_null(find_text("CHARGER UNE PARTIE"))
	assert_true(texts(menu).has("Version bêta %s" % AppVersion.current()))
	assert_no_raw_keys()


func test_without_saves_offers_no_continue_and_no_count() -> void:
	var menu := _menu([])
	assert_null(find_text("CONTINUER"))
	assert_null(menu.continue_entry)
	assert_null(menu.load_game_entry.badge)
	assert_eq(menu.new_game_entry.look, MenuEntry.Look.PRIMARY)


func test_finished_games_are_not_continued_but_counted() -> void:
	var menu := _menu([
		SavedGameSamples.game("Cousteau", 1, GameStatus.Value.VICTORY),
		SavedGameSamples.game("Nemo", 1, GameStatus.Value.DEFEAT),
	])
	assert_null(find_text("CONTINUER"))
	assert_eq(menu.load_game_entry.badge.label.text, "2")


func test_continues_the_latest_game_played_still_in_progress() -> void:
	var alice := SavedGameSamples.game("Alice", 14, GameStatus.Value.PLAYING, 1)
	var menu := _menu([
		SavedGameSamples.game("Marin", 3, GameStatus.Value.PLAYING, 30),
		alice,
		SavedGameSamples.game("Cousteau", 1, GameStatus.Value.VICTORY, 0),
	])
	assert_not_null(find_text("CONTINUER"))
	assert_not_null(find_text("Alice · Tour 14 · Normal"))
	assert_eq(menu.load_game_entry.badge.label.text, "3")
	assert_eq(menu.new_game_entry.look, MenuEntry.Look.OUTLINED)
	press("CONTINUER")
	assert_eq(_resumed, [alice] as Array[Game])


func test_opens_the_new_game_and_load_screens() -> void:
	_menu([])
	press("NOUVELLE PARTIE")
	press("CHARGER UNE PARTIE")
	assert_eq(_new_games, 1)
	assert_eq(_loads, 1)


func test_keeps_the_settings_in_the_top_right_corner() -> void:
	var menu := _menu([])
	assert_eq(menu.settings_button.get_parent(), menu.layout)
	assert_eq(menu.settings_button.size_flags_horizontal, Control.SIZE_SHRINK_END)
	assert_eq(menu.settings_button.size_flags_vertical, Control.SIZE_SHRINK_BEGIN)


func test_the_settings_offer_the_language_and_close() -> void:
	_menu([], LanguageChoice.Value.FRENCH)
	press(find_type("Button", host()).filter(func(node: Node) -> bool:
		return node is MenuSettingsButton)[0])
	var dialog := current_modal() as LanguageDialog
	assert_not_null(dialog)
	assert_true(dialog.picker.row(LanguageChoice.Value.FRENCH).check.visible)
	press("Fermer")
	assert_null(current_modal())


func test_picking_a_language_tells_it_and_the_dialog_reopens_on_it() -> void:
	var menu := _menu([])
	menu.settings_button.pressed.emit()
	press("English")
	assert_eq(_languages, [LanguageChoice.Value.ENGLISH] as Array[LanguageChoice.Value])
	press("Fermer")
	menu.settings_button.pressed.emit()
	assert_true((current_modal() as LanguageDialog).picker.row(LanguageChoice.Value.ENGLISH).check.visible)


func test_switches_the_menu_at_once_when_the_language_changes() -> void:
	var alice := SavedGameSamples.game("Alice", 14, GameStatus.Value.PLAYING, 1)
	var menu := _menu([alice])
	use_language("en")
	assert_not_null(find_text("NEW GAME"))
	assert_not_null(find_text("CONTINUE"))
	assert_not_null(find_text("Alice · Turn 14 · Normal"))
	assert_eq(menu.settings_button.tooltip_text, "Settings")
	assert_no_raw_keys()


func _menu(games: Array[Game], language := LanguageChoice.Value.AUTOMATIC) -> MainMenuScreen:
	var menu := mount(MainMenuScreen.new(SaveSections.of(games), language, modals())) as MainMenuScreen
	menu.continue_requested.connect(func(game: Game) -> void: _resumed.append(game))
	menu.new_game_requested.connect(func() -> void: _new_games += 1)
	menu.load_game_requested.connect(func() -> void: _loads += 1)
	menu.language_chosen.connect(func(choice: LanguageChoice.Value) -> void: _languages.append(choice))
	return menu
