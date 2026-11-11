extends AppFlowCase
## The way between the menu, the new game, the opening story and the game
## being played, and the language of the settings. The screens only tell what
## the player wants; the flow saves through the repository and shows the next
## one.


func test_opens_on_the_menu() -> void:
	_flow.show_menu()
	assert_true(_flow.current is MainMenuScreen)
	assert_eq(_screens.get_child_count(), 1)
	assert_not_null(find_text("NOUVELLE PARTIE"))
	assert_null(find_text("CONTINUER"))
	assert_eq(_playing, [false] as Array[bool])


func test_the_menu_offers_to_continue_the_latest_game_in_progress() -> void:
	_save("Marin")
	var alice := _save("Alice", 14)
	_flow.show_menu()
	assert_not_null(find_text("Alice · Tour 14 · Normal"))
	press("CONTINUER")
	assert_true(_flow.current is GamePlaceholderScreen)
	assert_eq((_flow.current as GamePlaceholderScreen).game.human_player().name, "Alice")
	assert_eq(alice.turn, 14)


func test_replaces_a_screen_by_the_next_and_frees_it() -> void:
	_flow.show_menu()
	var menu := _flow.current
	press("NOUVELLE PARTIE")
	assert_true(_flow.current is NewGameScreen)
	assert_eq(_screens.get_child_count(), 1)
	assert_true(menu.is_queued_for_deletion())


func test_starts_a_new_game_through_the_opening_story_to_the_game() -> void:
	_flow.show_menu()
	press("NOUVELLE PARTIE")
	var screen := _flow.current as NewGameScreen
	screen.name_field.text = "Alice"
	press(screen.start_button)
	assert_eq(_repository.load_all().games.size(), 1, "the game is saved at once")
	assert_true(_flow.current is OpeningStoryScreen)
	assert_eq(_playing.back(), false)
	press("Passer")
	var game := _flow.current as GamePlaceholderScreen
	assert_not_null(game)
	assert_eq(game.game.human_player().name, "Alice")
	assert_eq(_playing.back(), true)


func test_a_new_game_asks_for_a_name_first() -> void:
	_flow.show_new_game()
	press((_flow.current as NewGameScreen).start_button)
	assert_true(_flow.current is NewGameScreen)
	assert_eq(_repository.load_all().games.size(), 0)


func test_the_tutorial_starts_checked_until_a_game_is_well_advanced() -> void:
	_flow.show_new_game()
	assert_true((_flow.current as NewGameScreen).tutorial_switch.value())
	_save("Alice", TutorialOffer.EXPERIENCED_TURN)
	_flow.show_new_game()
	assert_false((_flow.current as NewGameScreen).tutorial_switch.value())


func test_quitting_saves_the_game_and_goes_back_to_the_menu() -> void:
	var alice := _save("Alice", 3)
	_flow.play(alice)
	alice.turn = 5
	press("Sauvegarder et quitter")
	assert_true(_flow.current is MainMenuScreen)
	assert_eq(_playing.back(), false)
	var saved := _repository.load_all().games
	assert_eq(saved.size(), 1, "the game replaces its file")
	assert_eq(saved[0].turn, 5)


func test_going_back_from_the_new_game_and_the_saves_leads_to_the_menu() -> void:
	_flow.show_new_game()
	press((_flow.current as NewGameScreen).bar.back_button)
	assert_true(_flow.current is MainMenuScreen)
	press("CHARGER UNE PARTIE")
	assert_true(_flow.current is LoadGameScreen)
	press((_flow.current as LoadGameScreen).bar.back_button)
	assert_true(_flow.current is MainMenuScreen)


func test_the_menu_counts_the_saved_games_it_reads_again_each_time() -> void:
	_flow.show_menu()
	assert_null((_flow.current as MainMenuScreen).load_game_entry.badge)
	_save("Alice")
	_flow.show_menu()
	assert_eq((_flow.current as MainMenuScreen).load_game_entry.badge.label.text, "1")


func test_keeps_the_language_chosen_in_the_settings() -> void:
	_flow.show_menu()
	(_flow.current as MainMenuScreen).language_chosen.emit(LanguageChoice.Value.ENGLISH)
	assert_eq(_language.choice(), LanguageChoice.Value.ENGLISH)
	assert_true(_flow.current is MainMenuScreen)


func test_the_menu_opens_the_language_settings_on_the_modals() -> void:
	_flow.show_menu()
	(_flow.current as MainMenuScreen).settings_button.pressed.emit()
	assert_true(current_modal() is LanguageDialog)


func test_the_language_not_saved_is_told_and_the_menu_stays() -> void:
	_block_folder()
	_language = LanguageSettings.new(_folder.path.path_join("blocker/settings.json"))
	_flow = AppFlow.new(_repository, _language, _screens, modals())
	_flow.show_menu()
	(_flow.current as MainMenuScreen).language_chosen.emit(LanguageChoice.Value.SPANISH)
	assert_eq(_language.choice(), LanguageChoice.Value.SPANISH)
	use_language("fr")


## Saves a game of [param player_name]; each save is an hour later than the
## last, so that the latest saved is the latest played.
