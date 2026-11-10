extends TestCase
## test/domain/game/game_factory_test.dart and game_factory_human_id_test
## .dart: the tutorial and the id of the human of a new game.


func test_game_factory_tutorial_a_new_game_starts_without_the_tutorial_by_default() -> void:
	var state := GameFactory.new_single_player("Nemo", 1).human_player().saved_objective_state
	assert_false(state.tutorial_enabled)
	assert_false(state.tips_enabled)
	assert_eq(state.completed.size(), 0)


func test_game_factory_tutorial_the_tutorial_flag_is_kept_with_nothing_completed() -> void:
	var game := GameFactory.new_single_player("Nemo", 1, Difficulty.Value.NORMAL, true)
	var state := game.human_player().saved_objective_state
	assert_true(state.tutorial_enabled)
	assert_true(state.tips_enabled)
	assert_eq(state.completed.size(), 0)


func test_the_id_of_the_human_is_drawn_when_none_is_given() -> void:
	var a := GameFactory.new_game("Nemo", 1)
	var b := GameFactory.new_game("Nemo", 1)
	assert_ne(a.human_player_id, b.human_player_id)
	assert_eq(a.human_player_id.length(), 36)


func test_a_given_id_names_the_human_of_a_game_without_faction() -> void:
	var game := GameFactory.new_game("Nemo", 1, Difficulty.Value.NORMAL, false, 0, null, "pinned")
	assert_eq(game.human_player_id, "pinned")
	assert_eq(game.human_player().id, "pinned")
	assert_eq(game.players.keys(), ["pinned"])


func test_a_given_id_names_the_human_of_a_game_against_factions() -> void:
	var personalities: Array[FactionPersonality.Value] = [FactionPersonality.Value.PEARL_ORDER]
	var game := GameFactory.new_game(
		"Nemo", 1, Difficulty.Value.NORMAL, false, 0, personalities, "pinned"
	)
	assert_eq(game.human_player_id, "pinned")
	assert_eq(game.players.keys(), ["pinned", "faction-pearlOrder"])


func test_the_single_player_factory_takes_it_too() -> void:
	var game := GameFactory.new_single_player("Nemo", 1, Difficulty.Value.NORMAL, false, "pinned")
	assert_eq(game.human_player_id, "pinned")


## Not in the Dart files: a game without a seed draws one below 2^31 - 1,
## and writes it in its journal.
func test_a_game_without_a_seed_draws_one() -> void:
	for game: Game in [GameFactory.new_single_player("Nemo"), GameFactory.new_game("Nemo")]:
		var seed_ := game.replay.map_seed
		assert_true(seed_ >= 0 and seed_ < 0x7FFFFFFF)
		assert_eq(game.levels[1].map_seed, seed_)
		assert_eq([game.replay.player_name, game.replay.exact], ["Nemo", true])
