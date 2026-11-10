extends TestCase
## What each level of the Coral Citadel costs and asks for. Dart tests
## coral_citadel_costs.dart through BuildingCostCalculator only, which never
## asks for a level out of range.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_costs_grow_and_end_with_the_pearls() -> void:
	var cost := CoralCitadelCosts.coral_citadel_cost(1)
	assert_eq(cost, {CORAL: 400, ORE: 400, ENERGY: 200, PEARL: 10})
	assert_eq(cost.keys(), [CORAL, ORE, ENERGY, PEARL])


func test_a_level_out_of_range_costs_nothing() -> void:
	assert_eq(CoralCitadelCosts.coral_citadel_cost(-1), {})
	assert_eq(CoralCitadelCosts.coral_citadel_cost(5), {})


func test_asks_for_the_headquarters_from_level_1_to_5_only() -> void:
	assert_eq(CoralCitadelCosts.coral_citadel_prereqs(0), {})
	assert_eq(CoralCitadelCosts.coral_citadel_prereqs(1), {BuildingType.Value.HEADQUARTERS: 3})
	assert_eq(CoralCitadelCosts.coral_citadel_prereqs(5), {BuildingType.Value.HEADQUARTERS: 10})
	assert_eq(CoralCitadelCosts.coral_citadel_prereqs(6), {})
