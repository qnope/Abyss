extends AppFlowCase
## The game on show: its screen over its base in the world, every change of
## it saved, the way out through the settings.


func test_plays_a_game_on_its_screen_with_a_controller() -> void:
	var game := _save("Alice", 14)
	_flow.play(game)
	var hud := _flow.current as GameHud
	assert_not_null(hud)
	assert_eq(_flow.controller.hud, hud)
	assert_eq(_flow.controller.world, _world)
	assert_eq(hud.turn_bar.turn_label.text, "Tour 14")
	assert_eq(hud.language, _language.choice(), "the language of the player")


func test_the_base_of_the_game_stands_in_the_world() -> void:
	var game := _save("Alice")
	game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 2
	_flow.play(game)
	assert_eq(_world.base.buildings.names(), [&"Headquarters"] as Array[StringName])


func test_a_change_of_the_game_is_saved_by_its_session() -> void:
	var game := _save("Alice", 3)
	_flow.play(game)
	(_flow.current as GameHud).actions.set_tips_enabled(true)
	assert_true(_flow.controller.session.is_save_waiting(), "for the next frame")
	var saved := _saved_games()
	assert_eq(saved.size(), 1, "the game keeps its file")
	assert_true(ObjectiveMigration.state_of(saved[0], saved[0].human_player()).tips_enabled)


func test_leaving_the_game_gives_the_world_back_to_the_menus() -> void:
	var game := _save("Alice")
	game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 2
	_flow.play(game)
	(_flow.current as GameHud).show_tab(GameTab.Value.TECH)
	assert_false(_world.visible)
	_save_and_quit()
	assert_null(_flow.controller)
	assert_true(_flow.current is MainMenuScreen)
	assert_true(_world.visible)
	assert_eq(_world.base.buildings.names(), BaseScene.BUILT)


func test_playing_another_game_closes_the_first() -> void:
	var first := _flow.play.bind(_save("Alice"))
	first.call()
	var before := _flow.controller
	_flow.play(_save("Bob"))
	assert_ne(_flow.controller, before)
	assert_eq((_flow.current as GameHud).game.human_player().name, "Bob")


func test_a_language_picked_in_the_game_is_kept() -> void:
	_flow.play(_save("Alice"))
	(_flow.current as GameHud).open_settings()
	press("English")
	assert_eq(_language.choice(), LanguageChoice.Value.ENGLISH)
	use_language("fr")


func test_the_menu_after_the_game_continues_the_game_just_left() -> void:
	var alice := _save("Alice", 2)
	_flow.play(alice)
	alice.turn = 3
	_save_and_quit()
	assert_not_null(find_text("Alice · Tour 3 · Normal"))
