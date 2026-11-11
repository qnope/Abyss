extends TestCase
## test/domain/script/variant/plan_moves_test.dart.


func test_finds_the_way_down_to_the_kernel_on_a_new_map() -> void:
	var script := PlanScript.from_replay(_source(), ReplayVariant.new(false, false, 1.0, 0, 1.0, 6, true))

	var report := ScriptRunner.new(58).run(script, 1)

	assert_not_null(report.milestones.faille_captured)
	assert_not_null(report.milestones.cheminee_captured)
	assert_eq(report.milestones.kernel_captured, 50)
	assert_true(report.log.any(func(e: ScriptLogEntry) -> bool: return e.description.begins_with("Combat (")))


func test_plays_the_same_plan_with_other_dice() -> void:
	var script := PlanScript.from_replay(_source(), ReplayVariant.new(true, false))

	var report := ScriptRunner.new(40).run(script, 2)

	assert_eq(report.milestones.faille_captured, 30)
	assert_eq(report.milestones.cheminee_captured, 39)


func test_searches_for_a_target_not_revealed_yet_and_waits_for_it() -> void:
	var on_map := func(verb: String) -> Dictionary:
		return {"do": verb, "x": 0, "y": 0, "units": {"scout": 1}}
	var script := PlanScript.from_replay(
		DartJson.encode({"turns": {"1": [on_map.call("attackBase"), on_map.call("descend")]}}),
		ReplayVariant.new(false),
	)

	ScriptRunner.new(2).run(script, 1)

	assert_eq(script.pending().map(func(s: PlanStep) -> String: return s.verb()), ["attackBase", "descend"])


static func _source() -> String:
	return ReferenceFiles.text_of("scenarios/replays/victoire-tour-85.json")
