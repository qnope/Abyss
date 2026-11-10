extends VectorTestCase
## test/domain/fight/unit_boost_test.dart: the boosts the research gives the
## stats of the units. Then the boost section of units.json.


func test_unit_boost_none_leaves_every_stat_unchanged() -> void:
	assert_eq(UnitBoost.none().atk(6), 6)
	assert_eq(UnitBoost.none().def(6), 6)
	assert_eq(UnitBoost.none().hp(25), 25)


func test_unit_boost_applies_each_percent_to_its_own_stat_rounded() -> void:
	var boost := UnitBoost.new(20, 30, 10)
	assert_eq(boost.atk(5), 6)
	assert_eq(boost.def(6), 8)  # 7.8 -> 8
	assert_eq(boost.hp(25), 28)  # 27.5 -> 28


func test_unit_boost_tier_bonuses_stack_additively() -> void:
	var boost := UnitBoost.new(30 + 20 + 30)
	assert_eq(boost.atk(10), 18)


## Not in the Dart file: what a boost holds, and none() without any.
func test_holds_its_three_percents() -> void:
	var boost := UnitBoost.new(20, 30, 10)
	assert_eq([boost.atk_percent, boost.def_percent, boost.hp_percent], [20, 30, 10])
	var none := UnitBoost.none()
	assert_eq([none.atk_percent, none.def_percent, none.hp_percent], [0, 0, 0])


func test_boost_vectors() -> void:
	var cases := VectorFile.new("units").cases("boost")
	assert_eq(cases.size(), 21)
	for case: Dictionary in cases:
		var percent: int = case["percent"]
		var stats: Array = case["stats"]
		var atk := []
		var def := []
		var hp := []
		for stat: int in stats:
			atk.append(UnitBoost.new(percent).atk(stat))
			def.append(UnitBoost.new(0, percent).def(stat))
			hp.append(UnitBoost.new(0, 0, percent).hp(stat))
		assert_same(atk, case["out"], str(case))
		assert_same(def, case["out"], str(case))
		assert_same(hp, case["out"], str(case))
