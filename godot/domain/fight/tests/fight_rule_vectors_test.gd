extends VectorTestCase
## reference/vectors/fight_rules.json: the rules of one blow and the stats of
## what fights, as the Dart rules answer. Its monsters are read by
## monster_unit_stats_test.gd.

var _vectors := VectorFile.new("fight_rules")


func test_damage() -> void:
	var cases := _vectors.cases("damage")
	assert_eq(cases.size(), 18)
	for case: Dictionary in cases:
		var atk: int = case["atk"]
		var defs: Array = case["defs"]
		var out := []
		for def: int in defs:
			out.append([
				DamageCalculator.compute(atk, def),
				DamageCalculator.compute(atk, def, true),
				DamageCalculator.compute(atk, def, false, true),
				DamageCalculator.compute(atk, def, false, false, 2),
				DamageCalculator.compute(atk, def, true, false, 4),
			])
		assert_same(out, case["out"], "atk %d" % atk)


func test_guardians() -> void:
	var cases := _vectors.cases("guardians")
	assert_eq(cases.size(), 3)
	var guardians: Dictionary[String, Callable] = {
		"faille": GuardianFactory.for_faille,
		"cheminee": GuardianFactory.for_cheminee,
		"kernel": GuardianFactory.for_volcanic_kernel,
	}
	for case: Dictionary in cases:
		var of: String = case["of"]
		var side: Array[Combatant] = guardians[of].call()
		assert_same(FightInputs.runs_of(side), case["out"], of)


func test_attack_damage() -> void:
	var cases := _vectors.cases("attackDamage")
	assert_eq(cases.size(), 208)
	for case: Dictionary in cases:
		var attacker := FightInputs.combatant(case["attacker"])
		var target := FightInputs.combatant(case["target"])
		var out := {
			"role": DartEnum.name_of(CombatRole.Value, attacker.role),
			"hunts": MonsterRules.hunts(attacker),
			"multiplier": MonsterRules.multiplier(attacker, target),
			"damage": AttackDamage.compute(attacker, target),
			"crit": AttackDamage.compute(attacker, target, true),
		}
		assert_same(out, case["out"], str(case))
