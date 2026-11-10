extends VectorTestCase
## reference/vectors/fight_planning.json, the assault sections: the chances
## the game shows before an assault on a guardian, as the Dart rules answer.

var _vectors := VectorFile.new("fight_planning")


func test_assault_chance() -> void:
	var cases := _vectors.cases("assaultChance")
	assert_eq(cases.size(), 30, "3 targets, 10 armies")
	for case: Dictionary in cases:
		var target := VectorInputs.value(AssaultTarget.Value, case["target"]) as AssaultTarget.Value
		var army := FightInputs.army(case["army"])
		var boost := FightInputs.boost(case["boost"])
		var out := _chance(AssaultRehearsals.chance_of(army, target, boost))
		out["harpoonists"] = AssaultRehearsals.harpoonists_for(army, target, boost, 300)
		assert_same(out, case["out"], "%s %s" % [case["target"], case["army"]])


func test_assault_rating() -> void:
	var cases := _vectors.cases("assaultRating")
	assert_eq(cases.size(), 31)
	for case: Dictionary in cases:
		var wins: int = case["wins"]
		var rehearsals: int = case["rehearsals"]
		var out := _chance(AssaultChance.new(wins, rehearsals))
		assert_same(out, case["out"], "%d/%d" % [wins, rehearsals])


func _chance(c: AssaultChance) -> Dictionary:
	return {
		"wins": c.wins,
		"rehearsals": c.rehearsals,
		"rate": c.rate(),
		"rating": DartEnum.name_of(AssaultRating.Value, c.rating()),
	}
