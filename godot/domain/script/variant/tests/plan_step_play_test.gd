extends TestCase
## Not in the Dart files: the ways a step of a plan fails that no game of
## the Dart tests reaches, and a plan that stops with the game.


func test_a_step_with_none_of_its_units_left_fails() -> void:
	var log: Array[ScriptLogEntry] = []
	var turn := _turn(log)
	var step := PlanStep.new(1, 0, {"do": "fight", "x": 3, "y": 3, "units": {"harpoonist": 5}})

	assert_false(PlanMoves.play_step(turn, step, ReplayVariant.new()))
	assert_eq(log, [] as Array[ScriptLogEntry])


## Where Dart throws on an action it cannot read, the step logs the error
## and fails.
func test_a_step_the_codec_cannot_read_fails() -> void:
	expect_error("Action inconnue : nope")

	assert_false(PlanMoves.play_step(_turn(), PlanStep.new(1, 0, {"do": "nope"}), ReplayVariant.new()))


func test_on_a_new_map_a_step_aiming_at_no_known_part_searches_for_it() -> void:
	var log: Array[ScriptLogEntry] = []
	var turn := _turn(log)
	turn.player.units_on_level(1)[UnitType.Value.SCOUT].count = 2
	var step := PlanStep.new(1, 0, {"do": "attackPost", "x": 3, "y": 3, "units": {"scout": 1}})

	assert_false(PlanMoves.play_step(turn, step, ReplayVariant.new(false)))
	assert_eq(log.map(func(e: ScriptLogEntry) -> String: return e.description), [
		"Explorer (15, 7)", "Explorer (15, 7)",
	], "the two scouts sent out")


func test_a_game_over_plays_no_step() -> void:
	var source := DartJson.encode({"turns": {"1": [{"do": "upgrade", "building": "algaeFarm"}]}})
	var script := PlanScript.from_replay(source, ReplayVariant.new())
	var turn := _turn()
	turn.game.status = GameStatus.Value.DEFEAT

	script.play_turn(turn)

	assert_eq(script.pending().size(), 1)


static func _turn(log: Array[ScriptLogEntry] = []) -> ScriptTurn:
	var game := GameFactory.new_single_player("Nemo", 1)
	CheatCodes.apply(game.human_player())
	return ScriptTurn.new(game, DartRandom.new(1, false), log)
