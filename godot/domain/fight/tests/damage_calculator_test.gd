extends TestCase
## test/domain/fight/damage_calculator_test.dart: the damage of one attack.


func test_compute_returns_atk_when_defender_has_no_defense() -> void:
	assert_eq(DamageCalculator.compute(10, 0), 10)


func test_compute_defense_equal_to_the_armour_constant_halves_damage() -> void:
	assert_eq(DamageCalculator.compute(10, 10), 5)


func test_compute_floors_fractional_damage_so_small_def_already_matters() -> void:
	# 5 * 10 / 12 = 4.17 -> floor -> 4
	assert_eq(DamageCalculator.compute(5, 2), 4)
	# 2 * 10 / 16 = 1.25 -> floor -> 1
	assert_eq(DamageCalculator.compute(2, 6), 1)


func test_compute_clamps_to_minimum_of_1_when_defense_is_overwhelming() -> void:
	assert_eq(DamageCalculator.compute(1, 1000), 1)


func test_compute_triples_damage_on_critical_hit_with_no_defense() -> void:
	assert_eq(DamageCalculator.compute(10, 0, true), 30)


func test_compute_triples_clamped_minimum_on_critical_hit() -> void:
	assert_eq(DamageCalculator.compute(1, 1000, true), 3)


func test_compute_ignore_def_deals_full_atk_whatever_the_defense() -> void:
	assert_eq(DamageCalculator.compute(10, 20, false, true), 10)


func test_compute_multiplier_scales_damage_before_the_crit() -> void:
	assert_eq(DamageCalculator.compute(8, 10, false, false, 2), 8)
	assert_eq(DamageCalculator.compute(8, 10, true, false, 2), 24)


func test_compute_matches_the_explicit_formula_for_several_combinations() -> void:
	var cases: Array[Vector3i] = [
		Vector3i(100, 0, 100),
		Vector3i(100, 10, 50),
		Vector3i(100, 30, 25),
		Vector3i(50, 5, 33),  # 500/15 = 33.3 -> 33
		Vector3i(7, 4, 5),  # 70/14 = 5
	]
	for c: Vector3i in cases:
		assert_eq(DamageCalculator.compute(c.x, c.y), c.z, "atk=%d def=%d" % [c.x, c.y])


## Not in the Dart file: the constant of the formula, and a negative DEF,
## which counts as none.
func test_holds_the_armour_constant_and_reads_a_negative_def_as_none() -> void:
	assert_eq(DamageCalculator.ARMOUR_CONSTANT, 10)
	assert_eq(DamageCalculator.compute(7, -9), 7)
