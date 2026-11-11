extends TestCase
## test/domain/replay/replay_difficulty_test.dart, its first test. 'a replay
## plays again in the difficulty it was exported in' and 'a scenario without
## difficulty takes the one of the runner' wait for `ScenarioParser` and
## `ScriptRunner`, the runners of `script`.


func test_the_export_names_the_difficulty_of_the_game() -> void:
	var game := GameFactory.new_single_player("Nemo", 42, Difficulty.Value.HARD)

	assert_eq(ReplayExport.to_json(game)["difficulty"], "hard")
