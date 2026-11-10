extends VectorTestCase
## A cost that grows by 1.6 a level, as exponentialCost of
## lib/domain/resource/exponential_cost.dart rounds it. Dart tests it
## through the costs of the buildings and of the research only.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE


func test_the_first_step_costs_the_base() -> void:
	assert_eq(ExponentialCost.exponential_cost({CORAL: 60, ORE: 40}, 0), {CORAL: 60, ORE: 40})


func test_scales_each_resource_by_1_6_a_step_rounded_to_the_nearest() -> void:
	assert_eq(ExponentialCost.exponential_cost({CORAL: 60, ORE: 40}, 1), {CORAL: 96, ORE: 64})
	# 60 * 1.6^5 = 629.1456 ; 40 * 1.6^5 = 419.4304
	assert_eq(ExponentialCost.exponential_cost({CORAL: 60, ORE: 40}, 5), {CORAL: 629, ORE: 419})


func test_keeps_the_resources_in_the_order_of_the_base() -> void:
	assert_eq(ExponentialCost.exponential_cost({ORE: 1, CORAL: 2}, 3).keys(), [ORE, CORAL])
	assert_eq(ExponentialCost.exponential_cost({}, 3), {})


func test_grows_by_the_ratio_dart_names() -> void:
	assert_eq(
		float(ExponentialCost.GROWTH_NUMERATOR) / ExponentialCost.GROWTH_DENOMINATOR,
		ExponentialCost.COST_GROWTH_PER_LEVEL
	)


func test_a_negative_step_is_refused() -> void:
	expect_error("ExponentialCost.exponential_cost: the step -1 is negative")
	assert_eq(ExponentialCost.exponential_cost({CORAL: 60, ORE: 40}, -1), {CORAL: 0, ORE: 0})


func test_exponential_cost_vectors() -> void:
	var cases := VectorFile.new("buildings").cases("exponentialCost")
	assert_eq(cases.size(), 90)
	for case: Dictionary in cases:
		var base: Dictionary[ResourceType.Value, int] = VectorInputs.amounts(
			ResourceType.Value, case["base"]
		)
		var step: int = case["step"]
		var cost := ExponentialCost.exponential_cost(base, step)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))
