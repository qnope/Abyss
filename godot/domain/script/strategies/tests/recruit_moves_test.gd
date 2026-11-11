extends TestCase
## test/domain/script/strategies/recruit_moves_test.dart: the algae margin
## a script recruits against.


func _turn(difficulty: Difficulty.Value) -> ScriptTurn:
	var game := GameFactory.new_single_player("p", 5, difficulty)
	game.human_player().buildings[BuildingType.Value.ALGAE_FARM].level = 5
	return ScriptSamples.turn(game)


func test_the_algae_margin_counts_the_production_of_the_difficulty() -> void:
	var easy := RecruitMoves.algae_margin(_turn(Difficulty.Value.EASY))
	var normal := RecruitMoves.algae_margin(_turn(Difficulty.Value.NORMAL))
	var hard := RecruitMoves.algae_margin(_turn(Difficulty.Value.HARD))

	assert_true(easy > normal)
	assert_true(hard < normal)


func test_the_algae_margin_counts_a_cold_current_endured_this_turn() -> void:
	var calm := _turn(Difficulty.Value.NORMAL)
	var cold := _turn(Difficulty.Value.NORMAL)
	cold.player.event_state.activate(RandomEventType.Value.COLD_CURRENT, cold.game.turn)
	assert_true(RecruitMoves.algae_margin(cold) < RecruitMoves.algae_margin(calm))
