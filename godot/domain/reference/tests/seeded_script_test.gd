extends TestCase
## test/domain/reference/seeded_script_test.dart.


func test_a_strategy_alone_leaves_a_journal_that_is_not_exact() -> void:
	var capture := GameCapture.new()
	ScriptRunner.new(25, Difficulty.Value.NORMAL, null, capture).run(ConquestStrategy.new(), 3)

	assert_false(ReplayExport.is_exact(capture.game()))


func test_played_seeded_the_same_strategy_leaves_an_exact_journal() -> void:
	var capture := GameCapture.new()
	ScriptRunner.new(25, Difficulty.Value.NORMAL, null, capture).run(SeededScript.new(ConquestStrategy.new(), 3, capture), 3)
	var journal := capture.game().replay

	assert_true(ReplayExport.is_exact(capture.game()))
	assert_eq(journal.end_turn_seeds.keys(), range(1, 26))
	var rolled: Array[Dictionary] = []
	var played := 0
	for turn: int in journal.actions:
		for action: Dictionary in journal.actions_of(turn):
			played += 1
			if action["do"] == "collect" or action["do"] == "fight":
				rolled.append(action)
	assert_false(rolled.is_empty())
	assert_true(rolled.all(func(a: Dictionary) -> bool: return a["seed"] is int))
	assert_true(played > 40)


func test_the_same_seed_plays_the_same_game_another_seed_another_one() -> void:
	assert_eq(_play(4), _play(4))
	assert_ne(_play(4), _play(5))


func test_is_the_script_it_wraps_for_everything_else() -> void:
	var magma: Array[FactionPersonality.Value] = [FactionPersonality.Value.MAGMA_SMITHS]
	var inner := TimelineScript.new("timeline", {}, null, "Nemo", 12, Difficulty.Value.HARD, 9, magma, {2: 77})
	var script := SeededScript.new(inner, 1, ActionExecutor.new())

	assert_eq(script.name(), "timeline")
	assert_eq(script.player_name(), "Nemo")
	assert_eq(script.map_seed(), 12)
	assert_eq(script.difficulty(), Difficulty.Value.HARD)
	assert_eq(script.last_turn(), 9)
	assert_eq(script.factions(), magma)
	assert_false(script.factions_play())
	assert_true(SeededScript.new(IdleScript.new(), 1, ActionExecutor.new()).factions_play())


func test_keeps_the_seed_a_replay_recorded_for_an_end_of_turn_and_draws_the_others() -> void:
	var inner := TimelineScript.new("t", {}, null, null, null, null, null, [], {2: 77})
	var script := SeededScript.new(inner, 1, ActionExecutor.new())

	assert_eq(script.end_turn_random(2).initial_seed, 77)
	assert_true(script.end_turn_random(3).is_seeded)
	assert_ne(script.end_turn_random(4).initial_seed, script.end_turn_random(5).initial_seed)


func _play(seed_: int) -> String:
	var capture := GameCapture.new()
	ScriptRunner.new(20, Difficulty.Value.NORMAL, null, capture).run(SeededScript.new(ConquestStrategy.new(), seed_, capture), seed_)
	return ReplayExport.to_text(capture.game())
