extends TestCase
## test/domain/script/variant/plan_leviathan_test.dart.


func test_a_plan_that_defends_holds_the_faille_it_is_warned_about() -> void:
	assert_eq(_strike(ReplayVariant.new(true, false, 1.0, 0, 1.0, 6, true)), AttackOutcome.Value.REPELLED)


func test_a_plan_that_does_not_defend_leaves_it_to_the_guardians() -> void:
	assert_eq(_strike(ReplayVariant.new(true, false)), AttackOutcome.Value.POST_TAKEN)


static func _strike(variant: ReplayVariant) -> AttackOutcome.Value:
	var war := LeviathanScene.of()
	war.put(war.human(), 1, {UnitType.Value.GUARDIAN: 60, UnitType.Value.DOME_BREAKER: 60})
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war))
	var idle := DartJson.encode({"name": "plan", "player": "Test", "turns": {}})
	PlanScript.from_replay(idle, variant).play_turn(ScriptTurn.new(war.game, DartRandom.new(5), []))
	return LeviathanScene.end_turn(war).report.outcome()
