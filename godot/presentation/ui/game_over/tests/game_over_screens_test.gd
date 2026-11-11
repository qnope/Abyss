extends UiTestCase
## test/presentation/screens/game/defeat_screen_test.dart and
## victory_screen_test.dart: the two ends of a game.

var _told: Array[StringName] = []
var _statistics := GameStatistics.new(27, 40, 1, 5000, 2, 4)


func _defeat(winner: Variant = null, analysis: DefeatAnalysis = null) -> DefeatScreen:
	var screen := DefeatScreen.new(_statistics, 26, winner, analysis)
	screen.action_chosen.connect(_told.append)
	return mount(screen)


func _victory() -> VictoryScreen:
	var screen := VictoryScreen.new(GameStatistics.new(42, 15, 3, 9001))
	screen.action_chosen.connect(_told.append)
	return mount(screen)


func test_the_defeat_names_the_turn_the_base_fell_after_how_many_raids() -> void:
	var screen := _defeat()
	assert_eq(screen.title_label.text, "DÉFAITE")
	assert_eq(screen.subtitle_label.text, "Votre base est tombée à la fin du tour 26, après 3 raids perdus d'affilée.")
	assert_eq(screen.lore_label.text, "La Fosse a repris ton dôme. L'archiviste ajoute une ligne à ses registres.")
	assert_eq(screen.title_label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_the_defeat_names_the_faction_that_tamed_the_volcano() -> void:
	var screen := _defeat("La Horde des Murènes")
	assert_eq(screen.subtitle_label.text, "La Horde des Murènes a dompté le Volcan au tour 26.")
	assert_eq(screen.lore_label.text, "Ton dôme vivra désormais de sa lumière.")


func test_the_defeat_shows_the_raid_statistics() -> void:
	_defeat()
	assert_not_null(find_text("Raids repoussés : 2"))
	assert_not_null(find_text("Raids perdus : 4"))
	assert_not_null(find_text("Tours joués : 27"))


func test_the_defeat_offers_the_menu_and_the_replay_export() -> void:
	var screen := _defeat()
	assert_null(find_text("Continuer en mode libre"))
	assert_eq(screen.buttons.keys(), [GameOverAction.MENU, GameOverAction.EXPORT])
	assert_eq(screen.buttons[GameOverAction.EXPORT].theme_type_variation, &"OutlinedButton")
	var asked: Array[StringName] = []
	screen.menu_requested.connect(asked.append.bind(&"menu"))
	screen.export_requested.connect(asked.append.bind(&"export"))
	press("Retour au menu")
	press("Exporter la partie")
	assert_eq(_told, [GameOverAction.MENU, GameOverAction.EXPORT] as Array[StringName])
	assert_eq(asked, [&"menu", &"export"] as Array[StringName])


func test_the_defeat_explains_the_fall_when_it_has_an_analysis() -> void:
	var raids: Array[LostRaid] = [LostRaid.new(26, MonsterLair.new(MonsterDifficulty.Value.EASY, 20), 0)]
	var screen := _defeat(null, DefeatAnalysis.new(raids, DefeatAdvice.Value.RAISE_AN_ARMY))
	assert_not_null(find_text("Ce qui s'est passé"))
	assert_not_null(screen)


func test_the_defeat_shows_no_explanation_without_an_analysis() -> void:
	_defeat()
	assert_null(find_text("Ce qui s'est passé"))


func test_the_defeat_follows_the_language() -> void:
	var screen := _defeat()
	use_language("en")
	assert_eq(screen.title_label.text, "DEFEAT")
	assert_not_null(find_text("Back to menu"))
	use_language("es")
	assert_no_raw_keys(screen)


func test_the_victory_tells_the_volcano_is_tamed() -> void:
	var screen := _victory()
	assert_eq(screen.title_label.text, "VICTOIRE !")
	assert_eq(screen.subtitle_label.text, "Vous avez conquis le Noyau Volcanique !")
	assert_eq(screen.lore_label.text, "Le Volcan est dompté : ses courants chauds remontent jusqu'au récif, et les autres dômes vivront de ta lumière.")
	assert_eq(screen.title_label.get_theme_color(&"font_color"), AbyssColors.WARNING)


func test_the_victory_shows_its_statistics() -> void:
	_victory()
	for shown: String in ["Tours joués : 42", "Monstres vaincus : 15", "Bases capturées : 3", "Ressources collectées : 9001"]:
		assert_not_null(find_text(shown), shown)


func test_the_victory_offers_free_play_then_the_menu() -> void:
	var screen := _victory()
	assert_eq(screen.buttons.keys(), [GameOverAction.CONTINUE, GameOverAction.MENU])
	var ways: Array[String] = []
	screen.continue_requested.connect(ways.append.bind("continue"))
	screen.menu_requested.connect(ways.append.bind("menu"))
	press("Continuer en mode libre")
	press("Retour au menu")
	assert_eq(ways, ["continue", "menu"] as Array[String])
	assert_eq(_told, [GameOverAction.CONTINUE, GameOverAction.MENU] as Array[StringName])


func test_the_victory_follows_the_language() -> void:
	var screen := _victory()
	use_language("en")
	assert_eq(screen.title_label.text, "VICTORY!")
	assert_not_null(find_text("Continue in free play"))
	use_language("es")
	assert_no_raw_keys(screen)


func test_the_screens_cover_the_page_and_cannot_be_dismissed() -> void:
	for screen: GameOverScreen in [_victory(), _defeat()]:
		assert_eq(screen.placement, ModalPanel.Placement.FULL)
		assert_false(screen.dismissible, "a touch outside or an escape does not end it")


func test_the_victory_opens_over_the_game_and_ends_with_its_close() -> void:
	var screen := VictoryScreen.new(_statistics)
	modals().open(screen)
	assert_eq(current_modal(), screen)
	screen.close()
	assert_null(current_modal())
