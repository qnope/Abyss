extends AppFlowCase
## The way through the saved games: resuming one, deleting one once confirmed,
## the empty list, a save that cannot be read, a save that cannot be written.


func test_resumes_a_game_chosen_among_the_saves() -> void:
	_save("Alice")
	var bob := _save("Bob", 9)
	_flow.show_load_game()
	press(_card_of("Bob").tap_button)
	assert_eq((_flow.current as GameHud).game.human_player().name, "Bob")
	assert_eq(bob.turn, 9)


func test_resumes_a_lost_game_on_its_defeat_screen() -> void:
	var lost := SavedGameSamples.game("Cousteau", 8, GameStatus.Value.DEFEAT)
	_repository.save(lost)
	_flow.show_load_game()
	press(_card_of("Cousteau").tap_button)
	assert_true(_flow.current is DefeatScreen)
	assert_eq((_flow.current as DefeatScreen).fall_turn, 7)
	assert_null(_flow.controller, "no game is being played")
	assert_eq(_playing, [false, false] as Array[bool], "a menu then the defeat, over the ambience")
	press("Retour au menu")
	assert_true(_flow.current is MainMenuScreen)


func test_the_defeat_screen_offers_the_replay_export_of_the_lost_game() -> void:
	var lost := SavedGameSamples.game("Cousteau", 8, GameStatus.Value.DEFEAT)
	_repository.save(lost)
	_flow.show_load_game()
	press(_card_of("Cousteau").tap_button)
	press("Exporter la partie")
	var dialog := current_modal() as ReplayExportDialog
	assert_not_null(dialog)
	assert_eq(dialog.game.human_player().name, "Cousteau")
	press("Fermer")
	assert_true(_flow.current is DefeatScreen, "still the way out")


func test_deletes_a_game_once_confirmed_and_shows_the_others() -> void:
	_save("Alice")
	_save("Bob")
	_flow.show_load_game()
	var saves := _flow.current as LoadGameScreen
	_card_of("Bob").menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	assert_eq(_repository.load_all().games.size(), 2, "nothing is deleted before the answer")
	press("Supprimer")
	assert_eq(_repository.load_all().games.size(), 1)
	assert_true(_flow.current is LoadGameScreen)
	assert_ne(_flow.current, saves)
	assert_eq((_flow.current as LoadGameScreen).list.cards().size(), 1)
	assert_not_null(find_text("Alice"))
	assert_null(find_text("Bob"))


func test_keeps_the_saves_when_a_deletion_fails() -> void:
	_save("Alice")
	_flow.show_load_game()
	DirAccess.remove_absolute(_repository.folder.path_join("game-1.json"))
	_card_of("Alice").menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	press("Supprimer")
	assert_true(_flow.current is LoadGameScreen)


func test_the_empty_saves_lead_to_a_new_game() -> void:
	_flow.show_load_game()
	press("NOUVELLE PARTIE")
	assert_true(_flow.current is NewGameScreen)


func test_a_save_that_cannot_be_read_is_reported_and_skipped() -> void:
	_save("Alice")
	var broken := FileAccess.open(_repository.folder.path_join("game-7.json"), FileAccess.WRITE)
	broken.store_string("not a game")
	broken.close()
	_flow.show_menu()
	assert_eq(_flow.unreadable.keys(), ["game-7.json"])
	assert_not_null(find_text("CONTINUER"), "the other saves still show")
	_flow.show_load_game()
	assert_eq((_flow.current as LoadGameScreen).list.cards().size(), 1)
	assert_eq(_flow.unreadable.keys(), ["game-7.json"])


func test_every_save_readable_leaves_nothing_reported() -> void:
	_save("Alice")
	_flow.show_menu()
	assert_true(_flow.unreadable.is_empty())


func test_the_game_goes_on_when_it_cannot_be_saved() -> void:
	_block_folder()
	# The engine logs the folder it cannot make, once for each save.
	expect_error("Could not create directory")
	expect_error("Could not create directory")
	_repository.folder = _folder.path.path_join("blocker/saves")
	_flow.show_new_game()
	var screen := _flow.current as NewGameScreen
	screen.name_field.text = "Alice"
	press(screen.start_button)
	assert_true(_flow.current is OpeningStoryScreen)
	press("Passer")
	_save_and_quit()
	assert_true(_flow.current is MainMenuScreen)
