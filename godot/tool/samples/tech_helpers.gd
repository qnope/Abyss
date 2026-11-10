class_name TechHelpers
extends RefCounted
## test/helpers/tech_helpers.dart: the researches the tests of godot/domain
## build, as the Dart tests do.


## An unlocked `branch` researched up to `level`, with `options` taken at
## its choice nodes (levels 2 then 4).
static func researched_branch(
	branch: TechBranch.Value, level: int, options: Array[TechOption.Value] = []
) -> TechBranchState:
	var choices: Array[int] = []
	choices.assign(options)
	return TechBranchState.new(branch, true, level, choices)


## All three branches, locked unless given in `states`.
static func tech_branches_with(
	states: Array[TechBranchState]
) -> Dictionary[TechBranch.Value, TechBranchState]:
	var branches: Dictionary[TechBranch.Value, TechBranchState] = {}
	for branch: TechBranch.Value in TechBranch.Value.values():
		branches[branch] = TechBranchState.new(branch)
	for state: TechBranchState in states:
		branches[state.branch] = state
	return branches
