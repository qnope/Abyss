extends NewGameCase
## test/presentation/screens/menu/new_game_screen_test.dart (and its l10n
## tests): the difficulty, the factions, the tutorial, the seed.


func test_asks_for_the_name_of_the_player() -> void:
	var screen := _screen()
	assert_eq(screen.bar.title(), "Nouvelle Partie")
	assert_eq(texts(screen).slice(1, 2), PackedStringArray(["Entrez votre nom"]))
	assert_eq(screen.name_field.placeholder_text, "Nom du joueur")
	assert_not_null(find_text("Commencer"))
	assert_no_raw_keys()


func test_offers_the_three_difficulties_normal_first() -> void:
	var screen := _screen()
	assert_eq(screen.difficulty_picker.bar.selected(), Difficulty.Value.NORMAL)
	assert_not_null(find_text("Facile"))
	assert_not_null(find_text("Difficile"))


func test_starts_in_the_difficulty_picked() -> void:
	_screen()
	_start("Nemo", func() -> void: press("Difficile"))
	assert_eq(_created[0].difficulty(), Difficulty.Value.HARD)


func test_starts_against_three_factions_unless_told_otherwise() -> void:
	_screen()
	assert_not_null(find_text("Factions rivales"))
	_start("Nemo")
	assert_eq(_created[0].factions().size(), 3)


func test_starts_against_the_number_of_factions_picked() -> void:
	var screen := _screen()
	_start("Nemo", func() -> void:
		press(screen.factions_picker.plus)
		press(screen.factions_picker.plus))
	assert_eq(_created[0].factions().size(), 5)


func test_starts_alone_when_no_faction_is_picked() -> void:
	var screen := _screen()
	_start("Nemo", func() -> void:
		for i in 3:
			press(screen.factions_picker.minus))
	assert_eq(_created[0].factions().size(), 0)
	assert_eq(_created[0].players.size(), 1)


func test_offers_the_tutorial_checked_for_a_first_game() -> void:
	var screen := _screen()
	assert_not_null(find_text("Tutoriel"))
	assert_not_null(find_text("Un guide t'accompagne sur les premiers tours"))
	assert_true(screen.tutorial_switch.value())
	_start("Nemo")
	var objectives := _created[0].human_player().saved_objective_state
	assert_true(objectives.tutorial_enabled)
	assert_true(objectives.tips_enabled)


func test_leaves_the_tutorial_unchecked_once_a_game_reached_turn_20() -> void:
	var old := GameFactory.new_single_player("Old", 1)
	old.turn = TutorialOffer.EXPERIENCED_TURN
	var screen := _screen([old])
	assert_false(screen.tutorial_switch.value())


func test_starts_without_the_tutorial_once_unchecked() -> void:
	var screen := _screen()
	_start("Nemo", func() -> void: screen.tutorial_switch.switch.button_pressed = false)
	var objectives := _created[0].human_player().saved_objective_state
	assert_false(objectives.tutorial_enabled)
	assert_false(objectives.tips_enabled)


func test_keeps_the_name_without_its_blanks_and_applies_the_cheat_code() -> void:
	_screen()
	_start("  qnope ")
	var player := _created[0].human_player()
	assert_eq(player.name, "qnope")
	assert_eq(player.buildings[BuildingType.Value.HEADQUARTERS].level, 7)


func test_the_same_seed_makes_the_same_map() -> void:
	_screen([], 7)
	_start("Nemo")
	assert_eq(_created[0].replay.map_seed, 7)
	assert_eq(_created[0].levels[1].map_seed, 7)


func test_back_tells_back() -> void:
	var screen := _screen()
	press(screen.bar.back_button)
	assert_eq(_backs, 1)


func test_follows_the_language() -> void:
	var screen := _screen()
	press("Commencer")
	use_language("en")
	assert_eq(screen.bar.title(), "New Game")
	assert_eq(screen.error_label.text, "Please enter a name")
	assert_eq(screen.start_button.text, "Start")
	assert_eq(screen.tutorial_switch.title_label.text, "Tutorial")
	assert_no_raw_keys()
