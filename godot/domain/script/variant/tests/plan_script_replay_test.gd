extends TestCase
## test/domain/script/variant/plan_script_test.dart, its games of the plan
## of turn 85: 'plays the human plan again on the same map and dice' and
## 'recruits for the announced raids when it defends'.


func test_plays_the_human_plan_again_on_the_same_map_and_dice() -> void:
	var script := PlanScript.from_replay(_source(), ReplayVariant.new())

	var report := ScriptRunner.new(50).run(script, 1)

	# The replay predates the research choices, the treasures, the monster
	# families and the rewards of the objectives: see the Dart file for the
	# count of the actions that lack resources.
	assert_eq(report.milestones.faille_captured, 30)
	assert_eq(report.milestones.cheminee_captured, 39)
	assert_eq(report.milestones.kernel_captured, 50)
	var failures := report.log.filter(func(e: ScriptLogEntry) -> bool:
		return not e.success and e.reason != ActionFailure.Value.NOTHING_TO_COLLECT)
	assert_eq(failures.size(), 5)


func test_recruits_for_the_announced_raids_when_it_defends() -> void:
	var recruits := func(v: ReplayVariant) -> int:
		var log := ScriptRunner.new(60).run(PlanScript.from_replay(_source(), v), 2).log
		return log.filter(func(e: ScriptLogEntry) -> bool:
			return e.success and e.description.begins_with("Recruter")).size()

	# With the original dice, the plan's own army beats every raid of the
	# normal difficulty; other dice bring raids it has to answer.
	var careful: int = recruits.call(ReplayVariant.new(true, false, 1.0, 0, 1.0, 6, true))
	var bold: int = recruits.call(ReplayVariant.new(true, false))
	assert_true(careful > bold, "%d > %d" % [careful, bold])


static func _source() -> String:
	return ReferenceFiles.text_of("scenarios/replays/victoire-tour-85.json")
