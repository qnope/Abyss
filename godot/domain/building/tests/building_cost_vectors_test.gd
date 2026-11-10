extends VectorTestCase
## reference/vectors/buildings.json: what an upgrade costs, how far a
## building goes and what it asks for, as BuildingCostCalculator answers in
## Dart.

var _vectors := VectorFile.new("buildings")


func test_upgrade_cost() -> void:
	var cases := _vectors.cases("upgradeCost")
	assert_eq(cases.size(), 204)
	for case: Dictionary in cases:
		var discount: int = case["discount"]
		var level: int = case["level"]
		var type := VectorInputs.value(BuildingType.Value, case["type"]) as BuildingType.Value
		var cost := BuildingCostCalculator.new(discount).upgrade_cost(type, level)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))


func test_limits() -> void:
	var cases := _vectors.cases("limits")
	assert_eq(cases.size(), 11)
	var calculator := BuildingCostCalculator.new()
	for case: Dictionary in cases:
		var type := VectorInputs.value(BuildingType.Value, case["type"]) as BuildingType.Value
		var prerequisites := []
		for target: int in calculator.max_level(type) + 2:
			prerequisites.append(
				VectorInputs.named(BuildingType.Value, calculator.prerequisites(type, target))
			)
		var out := {
			"capturedBase": VectorInputs.name_or_null(
				TransitionBaseType.Value, calculator.required_captured_base(type)
			),
			"capturedKernel": calculator.requires_captured_kernel(type),
			"maxLevel": calculator.max_level(type),
			"prerequisites": prerequisites,
		}
		assert_same(out, case["out"], str(case))
