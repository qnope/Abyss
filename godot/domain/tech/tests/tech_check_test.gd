extends TestCase
## test/domain/tech/tech_check_test.dart: whether a branch can be unlocked
## and a node researched now, and what is missing.

const MILITARY := TechBranch.Value.MILITARY
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY

var _branches := TechHelpers.tech_branches_with([])


func _rich() -> Dictionary[ResourceType.Value, GameResource]:
	return DomainSamples.resources({
		ORE: 500,
		ENERGY: 500,
		ResourceType.Value.CORAL: 500,
		ResourceType.Value.ALGAE: 500,
		ResourceType.Value.PEARL: 50,
	})


func _poor() -> Dictionary[ResourceType.Value, GameResource]:
	return DomainSamples.resources({ORE: 0, ENERGY: 0})


func _lab(level: int) -> Dictionary[BuildingType.Value, Building]:
	return DomainSamples.buildings({BuildingType.Value.LABORATORY: level})


func _unlock(lab: int, resources := _rich()) -> TechCheck:
	return TechCostCalculator.check_unlock(MILITARY, resources, _lab(lab), _branches)


func _research(target: int, lab: int, resources := _rich()) -> TechCheck:
	return TechCostCalculator.check_research(MILITARY, target, resources, _lab(lab), _branches)


func test_check_unlock_success_when_lab_level_1_branch_locked_resources_sufficient() -> void:
	assert_true(_unlock(1).can_act)


func test_check_unlock_fail_when_lab_level_0() -> void:
	var result := _unlock(0)
	assert_false(result.can_act)
	assert_eq(result.current_lab_level, 0)


func test_check_unlock_fail_when_branch_already_unlocked() -> void:
	_branches[MILITARY].unlocked = true
	assert_false(_unlock(1).can_act)


func test_check_unlock_fail_when_insufficient_resources() -> void:
	var result := _unlock(1, _poor())
	assert_false(result.can_act)
	assert_false(result.missing_resources.is_empty())


func test_check_research_success_branch_unlocked_level_0_to_1_lab_level_1() -> void:
	_branches[MILITARY].unlocked = true
	assert_true(_research(1, 1).can_act)


func test_check_research_fail_when_branch_locked() -> void:
	var result := _research(1, 1)
	assert_false(result.can_act)
	assert_true(result.branch_locked)


func test_check_research_fail_when_previous_node_not_researched_skip_level() -> void:
	_branches[MILITARY].unlocked = true
	# research_level is 0, trying to go to level 3
	var result := _research(3, 5)
	assert_false(result.can_act)
	assert_true(result.previous_node_missing)


func test_check_research_fail_when_lab_level_too_low() -> void:
	_branches[MILITARY].unlocked = true
	_branches[MILITARY].research_level = 2
	var result := _research(3, 1)
	assert_false(result.can_act)
	assert_eq(result.required_lab_level, 3)
	assert_eq(result.current_lab_level, 1)


func test_check_research_fail_when_max_level_reached() -> void:
	_branches[MILITARY].unlocked = true
	var result := _research(6, 5)
	assert_false(result.can_act)
	assert_true(result.is_max_level)


func test_check_research_fail_when_insufficient_resources() -> void:
	_branches[MILITARY].unlocked = true
	var result := _research(1, 1, _poor())
	assert_false(result.can_act)
	assert_false(result.missing_resources.is_empty())
