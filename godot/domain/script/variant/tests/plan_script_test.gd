extends TestCase
## test/domain/script/variant/plan_script_test.dart, but its games of the
## plan of turn 85 (plan_script_replay_test.gd).


func test_plays_each_turn_later_with_a_stretch_and_a_jitter() -> void:
	var stretched := PlanScript.from_replay(_upgrades(), ReplayVariant.new(true, true, 1.0, 0, 1.5))
	var jittered := PlanScript.from_replay(
		_upgrades(), ReplayVariant.new(true, true, 1.0, 2), DartRandom.new(3, false)
	)

	assert_eq(stretched.pending().map(func(s: PlanStep) -> int: return s.turn), [2, 6])
	for step: PlanStep in jittered.pending():
		var late: int = step.turn - [1, 4][step.rank]
		assert_true(late >= 0 and late <= 2, str(late))


func test_draws_the_delays_from_the_game_dice_when_given_none() -> void:
	var script := PlanScript.from_replay(_upgrades(), ReplayVariant.new(true, true, 1.0, 2))

	assert_eq(script.pending().map(func(s: PlanStep) -> int: return s.turn), [1, 4])
	ScriptRunner.new(1).run(script, 5)
	var last: PlanStep = script.pending().back()
	var late := last.turn - 4
	assert_true(late >= 0 and late <= 2, str(late))


func test_pins_the_map_and_raids_only_while_it_keeps_the_dice() -> void:
	var source := DartJson.encode({"mapSeed": 42, "turns": {}, "endTurnSeeds": {"1": 5}})

	assert_eq(PlanScript.from_replay(source, ReplayVariant.new()).map_seed(), 42)
	assert_not_null(PlanScript.from_replay(source, ReplayVariant.new()).end_turn_random(1))
	assert_null(PlanScript.from_replay(source, ReplayVariant.new(true, false)).end_turn_random(1))
	assert_null(PlanScript.from_replay(source, ReplayVariant.new(false)).map_seed())


func test_tries_a_failed_step_again_then_gives_it_up() -> void:
	var script := PlanScript.from_replay(
		_replay({"1": [{"do": "upgrade", "building": "barracks"}]}),
		ReplayVariant.new(true, true, 1.0, 0, 1.0, 2),
	)

	var report := ScriptRunner.new(6).run(script, 1)

	assert_eq(report.log.map(func(e: ScriptLogEntry) -> int: return e.turn), [1, 2, 3])
	assert_eq(script.pending().size(), 0)


func test_waits_as_long_as_it_takes_for_a_step_on_the_road() -> void:
	var script := PlanScript.from_replay(
		_replay({"1": [{"do": "attackKernel", "x": 10, "y": 10, "level": 3, "units": {"harpoonist": 1}}]}),
		ReplayVariant.new(false, true, 1.0, 0, 1.0, 1),
	)

	ScriptRunner.new(5).run(script, 1)

	assert_eq(script.pending().size(), 1)


## Not in the Dart file: a replay names its plan, its player and its turns
## as Dart reads them, a whole default for each one left out.
func test_names_the_script_after_the_replay_and_its_variant() -> void:
	var named := PlanScript.from_replay(_upgrades(), ReplayVariant.new(true, false))
	var bare := PlanScript.from_replay(DartJson.encode({"turns": {}}), ReplayVariant.new(), null, "mine")

	assert_eq(named.name(), "plan (même carte, autres dés)")
	assert_eq(named.player_name(), "Test")
	assert_eq(named.map_seed(), 42)
	assert_eq(bare.name(), "mine")
	assert_eq(bare.player_name(), "replay")
	assert_null(bare.map_seed())
	assert_eq(PlanScript.from_replay(DartJson.encode({"turns": {}}), ReplayVariant.new()).name(), "replay (même carte, mêmes dés)")


static func _replay(turns: Dictionary) -> String:
	return DartJson.encode({"name": "plan", "player": "Test", "mapSeed": 42, "turns": turns})


static func _upgrades() -> String:
	return _replay({
		"1": [{"do": "upgrade", "building": "headquarters"}],
		"4": [{"do": "upgrade", "building": "algaeFarm"}],
	})
