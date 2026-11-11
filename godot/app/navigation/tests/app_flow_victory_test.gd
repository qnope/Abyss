extends AppFlowCase
## The victory of the game on show: a kernel raised to the last level opens
## the victory screen over the game; "continue" goes on in free play, "menu"
## saves and leaves (game_screen_victory_test.dart). The kernel's upgrade
## itself is lot 12's: here a game stands at the last step.

const Type := BuildingType.Value


## A game one level from the end, on show, its building sheet raising the
## algae farm while the kernel is already at the last level.
func _play_at_the_gates() -> GameHud:
	var game := _save("Alice")
	var player := game.human_player()
	player.buildings[Type.HEADQUARTERS].level = 10
	player.buildings[Type.ALGAE_FARM].level = 1
	player.buildings[Type.VOLCANIC_KERNEL].level = 10
	for resource: GameResource in player.resources.values():
		resource.amount = resource.max_storage
	_flow.play(game)
	return _flow.current as GameHud


func _win(hud: GameHud) -> void:
	hud.open_building(Type.ALGAE_FARM)
	press("Améliorer")


func test_raising_the_last_level_opens_the_victory_screen_over_the_game() -> void:
	var hud := _play_at_the_gates()
	_win(hud)
	assert_eq(hud.game.status, GameStatus.Value.VICTORY)
	var screen := current_modal() as VictoryScreen
	assert_not_null(screen)
	assert_true(_flow.current is GameHud, "over the game, not instead of it")
	assert_eq(_repository.load_all().games[0].status, GameStatus.Value.VICTORY, "saved won")


func test_continuing_goes_on_in_free_play_and_saves_it() -> void:
	var hud := _play_at_the_gates()
	_win(hud)
	press("Continuer en mode libre")
	assert_eq(hud.game.status, GameStatus.Value.FREE_PLAY)
	assert_eq(_repository.load_all().games[0].status, GameStatus.Value.FREE_PLAY)
	assert_null(current_modal())
	assert_true(_flow.current is GameHud)
	assert_eq(_flow.controller.hud, hud, "the same game goes on")


func test_free_play_can_end_a_turn_without_a_second_victory() -> void:
	var hud := _play_at_the_gates()
	_win(hud)
	press("Continuer en mode libre")
	press("Tour suivant")
	press("Confirmer")
	assert_eq(hud.game.turn, 2)
	assert_true(current_modal() is TurnSummary)
	assert_eq(hud.game.status, GameStatus.Value.FREE_PLAY)


func test_the_menu_saves_and_leaves() -> void:
	var hud := _play_at_the_gates()
	_win(hud)
	press("Retour au menu")
	assert_true(_flow.current is MainMenuScreen)
	assert_null(_flow.controller)
	assert_null(current_modal(), "the victory screen does not stay over the menu")
	assert_eq(_repository.load_all().games[0].status, GameStatus.Value.VICTORY)
	assert_eq(hud.game.status, GameStatus.Value.VICTORY)
