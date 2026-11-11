extends TestCase
## test/domain/script/timeline_script_test.dart.


class _CountingScript:
	extends GameScript
	var turns: Array[int] = []

	func name() -> String:
		return "counting"

	func play_turn(turn: ScriptTurn) -> void:
		turns.append(turn.number())


func _upgrade(type: BuildingType.Value) -> Callable:
	return func(_random: DartRandom) -> Action: return UpgradeBuildingAction.new(type)


func test_plays_the_planned_actions_on_their_turn() -> void:
	var script := TimelineScript.new("hq", {2: [_upgrade(BuildingType.Value.HEADQUARTERS)]})

	var report := ScriptRunner.new(3).run(script, 1)

	assert_eq(report.log.size(), 1)
	assert_eq(report.log[0].turn, 2)
	assert_true(report.log[0].success)
	assert_eq(report.buildings[BuildingType.Value.HEADQUARTERS], 1)


func test_logs_a_refused_action_with_its_reason() -> void:
	var script := TimelineScript.new("too-soon", {1: [_upgrade(BuildingType.Value.BARRACKS)]})

	var report := ScriptRunner.new(1).run(script, 1)

	assert_false(report.log[0].success)
	assert_not_null(report.log[0].reason)
	assert_eq(report.failed_actions(), 1)


func test_hands_the_turns_left_out_to_the_fallback_script() -> void:
	var fallback := _CountingScript.new()
	var script := TimelineScript.new("mixed", {2: []}, fallback)

	ScriptRunner.new(4).run(script, 1)

	assert_eq(fallback.turns, [1, 3, 4] as Array[int])


## Not in the Dart file: a replay pins its game, plays each action as the
## player it names, stops on its last turn with the dice of its ends of
## turn, and leaves out an action of a player the game does not hold.
func test_a_replay_plays_each_action_as_its_player_on_its_own_game() -> void:
	var script := TimelineScript.new(
		"replay", {1: [_upgrade(BuildingType.Value.HEADQUARTERS), _upgrade(BuildingType.Value.HEADQUARTERS), _upgrade(BuildingType.Value.HEADQUARTERS)]},
		null, "Nemo", 12, Difficulty.Value.HARD, 2, [FactionPersonality.Value.PEARL_ORDER], {1: 77},
		{1: [null, "faction-pearlOrder", "nobody"]},
	)
	var watching := GameCapture.new()
	expect_error("Joueur inconnu dans le scénario : nobody")
	ScriptRunner.new(9, Difficulty.Value.NORMAL, null, watching).run(script, 1)

	var game := watching.game()
	assert_eq([script.player_name(), game.human_player().name, game.difficulty(), game.turn], ["Nemo", "Nemo", Difficulty.Value.HARD, 2])
	assert_eq(game.levels[1].map_seed, 12)
	assert_eq(game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level, 1)
	assert_eq(game.replay.actions_of(1).map(func(a: Dictionary) -> Variant: return a.get("player")), [null, "faction-pearlOrder"])
	assert_eq(game.replay.end_turn_seeds, {1: 77} as Dictionary[int, int])
	assert_false(script.factions_play())
	assert_eq(script.end_turn_random(1).initial_seed, 77)
	assert_null(script.end_turn_random(2))
	assert_eq(TimelineScript.new("named", {}).player_name(), "named")
