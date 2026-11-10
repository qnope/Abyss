extends VectorTestCase
## reference/vectors/tech.json: what the research costs and the state of a
## branch, as the Dart rules answer.

var _vectors := VectorFile.new("tech")


func _branch(case: Dictionary) -> TechBranch.Value:
	return VectorInputs.value(TechBranch.Value, case["branch"]) as TechBranch.Value


func test_unlock_cost() -> void:
	var cases := _vectors.cases("unlockCost")
	assert_eq(cases.size(), 12)
	for case: Dictionary in cases:
		var opened: int = case["opened"]
		assert_same(TechCostCalculator.cost_percent(opened), case["percent"], str(case))
		var cost := TechCostCalculator.unlock_cost(_branch(case), opened)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))


func test_research_cost() -> void:
	var cases := _vectors.cases("researchCost")
	assert_eq(cases.size(), 84)
	for case: Dictionary in cases:
		var level: int = case["level"]
		var opened: int = case["opened"]
		var cost := TechCostCalculator.research_cost(_branch(case), level, opened)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))


func test_branch_state() -> void:
	var cases := _vectors.cases("branchState")
	assert_eq(cases.size(), 84)
	for case: Dictionary in cases:
		var unlocked: bool = case["unlocked"]
		var level: int = case["level"]
		var taken: Array = case["choices"]
		var choices: Array[int] = []
		choices.assign(taken)
		var state := TechBranchState.new(_branch(case), unlocked, level, choices)
		var options := []
		for node: int in range(1, TechTree.MAX_LEVEL + 1):
			options.append(VectorInputs.name_or_null(TechOption.Value, state.option_at(node)))
		var out := {
			"options": options,
			"perks": VectorInputs.names(TechPerk.Value, state.perks().keys()),
			"tiers": state.tiers(),
		}
		assert_same(out, case["out"], str(case))
