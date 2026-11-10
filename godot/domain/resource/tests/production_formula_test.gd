extends TestCase
## test/domain/resource/production_formula_test.dart: what a building makes
## at a level.


func test_production_formula_3_level_squared_plus_2_returns_expected_values_for_levels_1_5() -> void:
	var formula := ProductionFormula.new(
		ResourceType.Value.ALGAE, func(level: int) -> int: return 3 * level * level + 2
	)
	assert_eq(formula.compute(1), 5)
	assert_eq(formula.compute(2), 14)
	assert_eq(formula.compute(3), 29)
	assert_eq(formula.compute(4), 50)
	assert_eq(formula.compute(5), 77)


func test_production_formula_level_0_returns_0() -> void:
	var formula := ProductionFormula.new(
		ResourceType.Value.ALGAE, func(level: int) -> int: return 3 * level * level + 2
	)
	assert_eq(formula.compute(0), 0)


func test_production_formula_2_level_squared_plus_1_returns_expected_values_for_levels_1_5() -> void:
	var formula := ProductionFormula.new(
		ResourceType.Value.ORE, func(level: int) -> int: return 2 * level * level + 1
	)
	assert_eq(formula.compute(1), 3)
	assert_eq(formula.compute(2), 9)
	assert_eq(formula.compute(3), 19)
	assert_eq(formula.compute(4), 33)
	assert_eq(formula.compute(5), 51)
