extends TestCase
## test/domain/tech/tech_branch_state_test.dart: how far a branch of the
## research went and the options taken on the way.

const MILITARY := TechBranch.Value.MILITARY
const RESOURCES := TechBranch.Value.RESOURCES
const EXPLORER := TechBranch.Value.EXPLORER
const A := TechOption.Value.A
const B := TechOption.Value.B


func _at(level: int, choices: Array[int] = []) -> TechBranchState:
	return TechBranchState.new(EXPLORER, true, level, choices)


func test_tech_branch_state_default_construction_unlocked_is_false_research_level_is_0() -> void:
	var state := TechBranchState.new(MILITARY)
	assert_eq(state.branch, MILITARY)
	assert_false(state.unlocked)
	assert_eq(state.research_level, 0)
	assert_eq(state.choices, [])


func test_tech_branch_state_construction_with_custom_values() -> void:
	var state := TechBranchState.new(RESOURCES, true, 3, [B])
	assert_eq(state.branch, RESOURCES)
	assert_true(state.unlocked)
	assert_eq(state.research_level, 3)
	assert_eq(state.option_at(2), B)


func test_option_at_is_null_on_a_tier_level() -> void:
	assert_null(_at(5, [1, 1]).option_at(1))
	assert_null(_at(5, [1, 1]).option_at(3))


func test_option_at_is_null_while_the_choice_node_is_not_researched() -> void:
	assert_null(_at(1).option_at(2))
	assert_null(_at(3, [1]).option_at(4))


func test_option_at_an_old_save_without_choices_defaults_to_option_a() -> void:
	var old := _at(5)
	assert_eq(old.option_at(2), A)
	assert_eq(old.option_at(4), A)


func test_option_at_reads_the_option_recorded_for_each_node() -> void:
	var state := _at(5, [B, A])
	assert_eq(state.option_at(2), B)
	assert_eq(state.option_at(4), A)


func test_choose_records_the_option_of_a_choice_node() -> void:
	var state := TechBranchState.new(MILITARY)
	state.choose(2, B)
	assert_eq(state.choices, [B])


func test_choose_fills_the_skipped_nodes_with_option_a() -> void:
	var state := TechBranchState.new(MILITARY)
	state.choose(4, B)
	assert_eq(state.choices, [A, B])


func test_choose_replaces_an_earlier_choice_of_the_same_node() -> void:
	var state := TechBranchState.new(MILITARY)
	state.choose(2, B)
	state.choose(2, A)
	assert_eq(state.choices, [A])


func test_perks_and_tiers_a_locked_branch_grants_nothing() -> void:
	var state := TechBranchState.new(MILITARY, false, 5, [1, 1])
	assert_eq(state.perks(), {})
	assert_eq(state.tiers(), 0)


func test_perks_and_tiers_perks_follow_the_options_taken_at_researched_nodes() -> void:
	var state := TechBranchState.new(MILITARY, true, 4, [B, A])
	assert_eq(
		state.perks().keys(), [TechPerk.Value.NACRE_SHELL, TechPerk.Value.LIVING_RAMPART]
	)
	assert_eq(state.tiers(), 2)


func test_perks_and_tiers_a_node_not_yet_researched_grants_no_perk() -> void:
	var state := TechBranchState.new(RESOURCES, true, 3)
	assert_eq(state.perks().keys(), [TechPerk.Value.INTENSIVE_FARMING])
	assert_eq(state.tiers(), 2)


func test_perks_and_tiers_tiers_count_levels_1_3_and_5() -> void:
	var tiers: Array[int] = []
	for level: int in range(0, 6):
		tiers.append(TechBranchState.new(EXPLORER, true, level).tiers())
	assert_eq(tiers, [0, 1, 1, 2, 2, 3])
