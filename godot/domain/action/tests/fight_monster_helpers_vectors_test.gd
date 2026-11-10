extends VectorTestCase
## reference/vectors/fight_aftermath.json, pctLost: the share of hit points
## an army lost, as FightMonsterHelpers.computePctLost answers it.


func test_pct_lost() -> void:
	var cases := VectorFile.new("fight_aftermath").cases("pctLost")
	assert_eq(cases.size(), 7)
	for case: Dictionary in cases:
		var max_hps: Array = case["maxHp"]
		var lefts: Array = case["left"]
		var initial: Array[Combatant] = []
		var final_c: Array[Combatant] = []
		for i: int in max_hps.size():
			var max_hp: int = max_hps[i]
			var left: int = lefts[i]
			initial.append(Combatant.new(CombatSide.Value.PLAYER, "harpoonist", max_hp, 5, 2, max_hp))
			final_c.append(Combatant.new(CombatSide.Value.PLAYER, "harpoonist", max_hp, 5, 2, left))
		assert_same(FightMonsterHelpers.compute_pct_lost(initial, final_c), case["out"], str(case))
