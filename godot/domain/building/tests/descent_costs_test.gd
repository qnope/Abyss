extends TestCase
## What the Descent Module and the Pressure Capsule cost. Dart tests
## descent_costs.dart through BuildingCostCalculator; its maps are constants.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_costs_in_the_order_of_dart() -> void:
	var module := DescentCosts.descent_module_cost()
	assert_eq(module, {CORAL: 200, ORE: 150, ENERGY: 80, PEARL: 5})
	assert_eq(module.keys(), [CORAL, ORE, ENERGY, PEARL])
	var capsule := DescentCosts.pressure_capsule_cost()
	assert_eq(capsule, {CORAL: 400, ORE: 300, ENERGY: 150, PEARL: 15})
	assert_eq(capsule.keys(), [CORAL, ORE, ENERGY, PEARL])


func test_the_costs_cannot_be_changed_as_dart_constants() -> void:
	assert_true(DescentCosts.descent_module_cost().is_read_only())
	assert_true(DescentCosts.pressure_capsule_cost().is_read_only())
	assert_false(BuildingCostCalculator.new().upgrade_cost(BuildingType.Value.DESCENT_MODULE, 0).is_read_only())
