extends TestCase
## Not in the Dart tests: what a TechCheck holds by default (Dart has no
## test of its own for tech_check.dart) and everything a check of
## TechCostCalculator says, which tech_check_test.dart reads in part.

const MILITARY := TechBranch.Value.MILITARY
const EXPLORER := TechBranch.Value.EXPLORER
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL

var _lab := DomainSamples.buildings({BuildingType.Value.LABORATORY: 5})


func test_misses_nothing_unless_told() -> void:
	var check := TechCheck.new(true)
	assert_true(check.can_act)
	assert_false(check.is_max_level)
	assert_eq(check.missing_resources, {})
	assert_eq(check.required_lab_level, 0)
	assert_eq(check.current_lab_level, 0)
	assert_false(check.branch_locked)
	assert_false(check.previous_node_missing)


func test_two_checks_share_no_map() -> void:
	TechCheck.new(false).missing_resources[ORE] = 3
	assert_eq(TechCheck.new(false).missing_resources, {})


func test_an_unlock_says_the_laboratory_it_needs_and_what_is_missing() -> void:
	var branches := TechHelpers.tech_branches_with([TechHelpers.researched_branch(EXPLORER, 0)])
	var stocks := DomainSamples.resources({ENERGY: 10, ORE: 100})
	var short := TechCostCalculator.check_unlock(MILITARY, stocks, _lab, branches)
	# One branch opened: the second unlock costs ore 45, energy 30.
	assert_eq(short.missing_resources, {ENERGY: 20})
	assert_eq([short.required_lab_level, short.current_lab_level], [1, 5])
	var none := TechCostCalculator.check_unlock(MILITARY, {}, {}, {})
	assert_eq([none.can_act, none.required_lab_level, none.current_lab_level], [false, 1, 0])
	assert_eq(none.missing_resources, {})
	var unbuilt := TechCostCalculator.check_unlock(MILITARY, {}, _lab, {})
	assert_eq(unbuilt.missing_resources.keys(), [ORE, ENERGY])
	assert_eq(unbuilt.missing_resources, {ORE: 30, ENERGY: 20})


func test_a_research_says_the_laboratory_it_needs_and_what_is_missing() -> void:
	var branches := TechHelpers.tech_branches_with([
		TechHelpers.researched_branch(EXPLORER, 4), TechHelpers.researched_branch(MILITARY, 0),
	])
	var stocks := DomainSamples.resources({ENERGY: 600, ORE: 492, PEARL: 4}, 5000)
	var short := TechCostCalculator.check_research(EXPLORER, 5, stocks, _lab, branches)
	# Two branches opened: energy 786, ore 492, pearl 10.
	assert_false(short.can_act)
	assert_eq(short.missing_resources.keys(), [ENERGY, PEARL])
	assert_eq(short.missing_resources, {ENERGY: 186, PEARL: 6})
	assert_eq([short.required_lab_level, short.current_lab_level], [5, 5])
	var paid := DomainSamples.resources({ENERGY: 786, ORE: 492, PEARL: 10}, 5000)
	var ready := TechCostCalculator.check_research(EXPLORER, 5, paid, _lab, branches)
	assert_true(ready.can_act)
	assert_eq(ready.missing_resources, {})
	assert_true(TechCostCalculator.check_research(MILITARY, 1, {}, _lab, {}).branch_locked)
