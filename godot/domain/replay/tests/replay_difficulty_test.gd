extends TestCase
## test/domain/replay/replay_difficulty_test.dart.


func test_the_export_names_the_difficulty_of_the_game() -> void:
	var game := GameFactory.new_single_player("Nemo", 42, Difficulty.Value.HARD)

	assert_eq(ReplayExport.to_json(game)["difficulty"], "hard")


func test_a_replay_plays_again_in_the_difficulty_it_was_exported_in() -> void:
	var live := GameFactory.new_single_player("Nemo", 42, Difficulty.Value.HARD)
	live.turn = 2
	var spy := LiveGames.SpyExecutor.new()

	ScriptRunner.new(60, Difficulty.Value.EASY, null, spy).run(ScenarioParser.parse(ReplayExport.to_text(live)), 1)

	assert_eq(spy.game.difficulty(), Difficulty.Value.HARD)


func test_a_scenario_without_difficulty_takes_the_one_of_the_runner() -> void:
	var spy := LiveGames.SpyExecutor.new()

	ScriptRunner.new(1, Difficulty.Value.EASY, null, spy).run(ScenarioParser.parse('{"turns": {}}'), 1)

	assert_eq(spy.game.difficulty(), Difficulty.Value.EASY)
