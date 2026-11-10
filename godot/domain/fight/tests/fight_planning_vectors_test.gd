extends VectorTestCase
## reference/vectors/fight_planning.json: the strength of a side and the
## fights rehearsed before they are fought, as the Dart rules answer. The
## assault sections are read by assault/tests/assault_vectors_test.gd.

var _vectors := VectorFile.new("fight_planning")


func test_strength() -> void:
	var cases := _vectors.cases("strength")
	assert_eq(cases.size(), 24)
	for case: Dictionary in cases:
		var players := FightInputs.runs(case["players"])
		var monsters := FightInputs.runs(case["monsters"])
		var out := [
			ArmyRehearsal.strength(players, monsters), ArmyRehearsal.strength(monsters, players),
		]
		assert_same(out, case["out"], str(case["fight"]))


func test_rehearsal() -> void:
	var cases := _vectors.cases("rehearsal")
	assert_eq(cases.size(), 39, "13 fights, 1, 8 and 20 rehearsals")
	for case: Dictionary in cases:
		var r := _rehearsal(case)
		var rehearsals: int = case["rehearsals"]
		var needing := []
		for n: int in rehearsals + 1:
			needing.append(r.wins(rehearsals, n))
		var out := {"hopeless": r.hopeless(), "wins": r.wins(rehearsals), "winsNeeding": needing}
		assert_same(out, case["out"], str(case["army"]))


func test_planner() -> void:
	var cases := _vectors.cases("planner")
	assert_eq(cases.size(), 65, "13 fights, 5 planners")
	for case: Dictionary in cases:
		var rehearsals: int = case["rehearsals"]
		var confidence: float = case["confidence"]
		var p := ArmyPlanner.new(rehearsals, confidence)
		var army := FightInputs.army(case["army"])
		var enemy := _enemy(case)
		var boost := FightInputs.boost(case["boost"])
		var admiral: bool = case["needsAdmiral"]
		var with_harpoonists := func(k: int) -> Dictionary[UnitType.Value, int]:
			var bigger: Dictionary[UnitType.Value, int] = army.duplicate()
			var have: int = army.get(UnitType.Value.HARPOONIST, 0)
			bigger[UnitType.Value.HARPOONIST] = have + k
			return bigger
		var smallest := []
		var max_ks: Array = case["maxKs"]
		for max_k: int in max_ks:
			smallest.append(p.smallest_winning(max_k, with_harpoonists, enemy, boost, Callable(), admiral))
		var out := {
			"winRate": p.win_rate(army, enemy, boost, Callable(), admiral),
			"wins": p.wins(army, enemy, boost, Callable(), admiral),
			"smallestWinning": smallest,
		}
		assert_same(out, case["out"], "%s %d@%s" % [case["army"], rehearsals, confidence])


func _rehearsal(case: Dictionary) -> ArmyRehearsal:
	var admiral: bool = case["needsAdmiral"]
	var boost := FightInputs.boost(case["boost"])
	return ArmyRehearsal.new(FightInputs.army(case["army"]), _enemy(case), boost, Callable(), admiral)


## `enemy()` of the case: fresh combatants from its runs at each call.
func _enemy(case: Dictionary) -> Callable:
	var runs: Array = case["enemy"]
	return func() -> Array[Combatant]: return FightInputs.runs(runs)
