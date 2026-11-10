extends TestCase
## The researches the tests of the domain share.

const MILITARY := TechBranch.Value.MILITARY
const EXPLORER := TechBranch.Value.EXPLORER


func test_builds_an_unlocked_branch_with_its_options() -> void:
	var state := TechHelpers.researched_branch(EXPLORER, 4, [TechOption.Value.B, TechOption.Value.A])
	assert_eq(state.branch, EXPLORER)
	assert_true(state.unlocked)
	assert_eq(state.research_level, 4)
	assert_eq(state.choices, [1, 0])
	assert_eq(TechHelpers.researched_branch(MILITARY, 1).choices, [])


func test_builds_the_three_branches_locked_unless_given() -> void:
	var given := TechHelpers.researched_branch(EXPLORER, 3)
	var branches := TechHelpers.tech_branches_with([given])
	assert_eq(branches.keys(), TechBranch.Value.values())
	assert_eq(branches[EXPLORER], given)
	assert_eq(branches[MILITARY].branch, MILITARY)
	assert_false(branches[MILITARY].unlocked)
	assert_false(TechHelpers.tech_branches_with([])[EXPLORER].unlocked)


func test_reads_the_effects_of_the_branches_given() -> void:
	var effects := TechHelpers.effects_of([TechHelpers.researched_branch(MILITARY, 3)])
	assert_eq(effects.tiers_of(MILITARY), 2)
	assert_eq(effects.tiers_of(EXPLORER), 0)
	assert_false(effects.halved)
