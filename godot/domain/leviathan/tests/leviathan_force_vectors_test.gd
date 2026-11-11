extends VectorTestCase
## reference/vectors/fight_rules.json, leviathan: the guardians that come
## back, scaled by the share of their strength the monsters keep, as the
## Dart rules answer.


func test_leviathan() -> void:
	var cases := VectorFile.new("fight_rules").cases("leviathan")
	assert_eq(cases.size(), 8)
	for case: Dictionary in cases:
		var percent: int = case["percent"]
		var force := LeviathanForce.combatants(percent)
		assert_same(FightInputs.runs_of(force), case["out"], str(case))
