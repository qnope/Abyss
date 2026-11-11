extends AppFlowCase
## The "next turn" of the game on show, from the press to the next playable
## state: the question, the turn saved, the summary on the modals, the screen
## redrawn once it is closed (game_screen_end_turn_test.dart,
## game_screen_turn_flow_test.dart).

const Type := BuildingType.Value


## A game of [param player_name] with a base that makes resources, on show.
func _play(player_name := "Alice") -> GameHud:
	var game := _save(player_name)
	for type: BuildingType.Value in [Type.HEADQUARTERS, Type.ALGAE_FARM, Type.CORAL_MINE, Type.SOLAR_PANEL]:
		game.human_player().buildings[type].level = 2
	_flow.play(game)
	return _flow.current as GameHud


func _saved_turn() -> int:
	return _repository.load_all().games[0].turn


func test_the_next_turn_button_asks_before_changing_anything() -> void:
	var hud := _play()
	press("Tour suivant")
	assert_true(current_modal() is TurnConfirmation)
	assert_eq(hud.game.turn, 1)
	press("Annuler")
	assert_eq(hud.game.turn, 1)
	assert_eq(hud.turn_bar.turn_label.text, "Tour 1")


func test_confirming_ends_the_turn_and_saves_the_game() -> void:
	var hud := _play()
	var coral := hud.game.human_player().resources[ResourceType.Value.CORAL].amount
	press("Tour suivant")
	press("Confirmer")
	assert_eq(hud.game.turn, 2)
	assert_eq(_saved_turn(), 2, "saved before the summary shows")
	assert_true(hud.game.human_player().resources[ResourceType.Value.CORAL].amount > coral)
	assert_eq(hud.turn_bar.turn_label.text, "Tour 2")
	var summary := current_modal() as TurnSummary
	assert_not_null(summary)
	assert_eq(summary.title(), "Tour 1 → Tour 2")
	assert_not_null(find_text("Corail", summary))


func test_the_summary_lines_are_what_the_domain_reports() -> void:
	var hud := _play()
	var forecast := TurnForecast.of(hud.game)
	press("Tour suivant")
	press("Confirmer")
	var summary := current_modal() as TurnSummary
	for change in summary.result.changes:
		assert_eq(change.produced, forecast.production.get(change.type, 0), "the question announced it")
		assert_not_null(find_text("+%d" % change.produced if change.consumed == 0
			else "+%d/-%d" % [change.produced, change.consumed], summary))


func test_closing_the_summary_redraws_the_screen() -> void:
	var hud := _play()
	press("Tour suivant")
	press("Confirmer")
	# A change nothing told: only the redraw after the summary shows it.
	hud.game.human_player().resources[ResourceType.Value.ENERGY].amount = 4321
	press("OK")
	assert_null(current_modal())
	assert_not_null(find_text("4321", hud.resource_bar))
	assert_true(_flow.current is GameHud, "the game goes on")


func test_a_turn_that_lost_the_game_leads_to_the_defeat_screen_then_the_menu() -> void:
	var hud := _play()
	hud.game.turn = 12
	hud.game.human_player().raid_state.lost_in_a_row = 2
	hud.game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 12)
	press("Tour suivant")
	press("Confirmer")
	assert_eq(hud.game.status, GameStatus.Value.DEFEAT)
	assert_true(_flow.current is GameHud, "the summary comes first")
	press("OK")
	var screen := _flow.current as DefeatScreen
	assert_not_null(screen)
	assert_eq(screen.fall_turn, 12)
	assert_null(_flow.controller)
	assert_true(_world.visible, "the world is the menus' again")
	assert_eq(_repository.load_all().games[0].status, GameStatus.Value.DEFEAT, "saved as lost")
	press("Retour au menu")
	assert_true(_flow.current is MainMenuScreen)


func test_the_game_lost_reopens_on_its_defeat_screen() -> void:
	_play()
	var hud := _flow.current as GameHud
	hud.game.turn = 12
	hud.game.human_player().raid_state.lost_in_a_row = 2
	hud.game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 12)
	press("Tour suivant")
	press("Confirmer")
	press("OK")
	press("Retour au menu")
	_flow.show_load_game()
	press(_card_of("Alice").tap_button)
	assert_true(_flow.current is DefeatScreen)
