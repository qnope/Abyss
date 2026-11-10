extends VectorTestCase
## reference/vectors/tech.json: the state of a branch of the research, as
## the Dart rules answer.

var _vectors := VectorFile.new("tech")


func test_branch_state() -> void:
	var cases := _vectors.cases("branchState")
	assert_eq(cases.size(), 84)
	for case: Dictionary in cases:
		var branch := VectorInputs.value(TechBranch.Value, case["branch"]) as TechBranch.Value
		var unlocked: bool = case["unlocked"]
		var level: int = case["level"]
		var taken: Array = case["choices"]
		var choices: Array[int] = []
		choices.assign(taken)
		var state := TechBranchState.new(branch, unlocked, level, choices)
		var options := []
		for node: int in range(1, TechTree.MAX_LEVEL + 1):
			options.append(VectorInputs.name_or_null(TechOption.Value, state.option_at(node)))
		var out := {
			"options": options,
			"perks": VectorInputs.names(TechPerk.Value, state.perks().keys()),
			"tiers": state.tiers(),
		}
		assert_same(out, case["out"], str(case))
