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
