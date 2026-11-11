extends UiTestCase
## game_screen_defeat_actions.dart (defeatRoute) and
## game_screen_victory_actions.dart: the screens of a game, read from it.


func _lost_game() -> Game:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.turn = 9
	game.status = GameStatus.Value.DEFEAT
	return game


func test_the_defeat_of_a_game_names_the_turn_before_the_one_it_stands_on() -> void:
	var screen := mount(GameOverScreens.defeat(_lost_game())) as DefeatScreen
	assert_eq(screen.fall_turn, 8)
	assert_null(screen.winner_name)
	assert_eq(screen.statistics_card.statistics.turns_played, 8)


func test_the_defeat_explains_a_fall_to_the_raids_from_the_history() -> void:
	var game := _lost_game()
	game.human_player().history_entries.append(HistorySamples.raid_entry(false))
	var screen := mount(GameOverScreens.defeat(game)) as DefeatScreen
	assert_not_null(find_text("Ce qui s'est passé"))
	assert_not_null(screen)


func test_the_defeat_has_no_explanation_without_a_lost_raid() -> void:
	mount(GameOverScreens.defeat(_lost_game()))
	assert_null(find_text("Ce qui s'est passé"))


func test_the_defeat_names_the_faction_whose_kernel_stands_at_the_last_level() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	var rival := war.attacker()
	rival.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	rival.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	war.game.status = GameStatus.Value.DEFEAT
	var screen := mount(GameOverScreens.defeat(war.game)) as DefeatScreen
	assert_eq(screen.winner_name, rival.name)
	assert_null(find_text("Ce qui s'est passé"), "the raids are not to blame")


func test_the_victory_of_a_game_shows_its_statistics() -> void:
	var game := GameFactory.new_single_player("Nemo", 1)
	game.turn = 31
	game.status = GameStatus.Value.VICTORY
	var screen := mount(GameOverScreens.victory(game)) as VictoryScreen
	assert_eq(screen.statistics_card.statistics.turns_played, 31)
	assert_eq(screen.statistics_card.statistics.turns_played, GameStatisticsCalculator.new().compute(game).turns_played)


func test_the_bare_layout_has_no_texts_of_its_own() -> void:
	var screen := mount(GameOverScreen.new(Color.WHITE, GameStatistics.new(1, 1, 0, 0), null, [])) as GameOverScreen
	assert_eq(screen.emblem_name(), "")
	assert_eq(screen.title_text(), "")
	assert_eq(screen.subtitle_text(), "")
	assert_eq(screen.lore_text(), "")
