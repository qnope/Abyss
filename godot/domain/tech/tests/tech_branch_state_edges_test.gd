extends TestCase
## Not in the Dart tests: what tech_branch_state.dart does with its lists,
## and where it throws (a choice that is no option, a level beyond the
## tree), which the port answers with a logged error.

const MILITARY := TechBranch.Value.MILITARY
const A := TechOption.Value.A
const B := TechOption.Value.B


func test_two_states_share_no_list_of_choices() -> void:
	var first := TechBranchState.new(MILITARY)
	first.choose(2, B)
	assert_eq(TechBranchState.new(MILITARY).choices, [])


func test_choose_writes_a_new_list_and_leaves_the_one_it_was_given() -> void:
	var given: Array[int] = [A]
	var state := TechBranchState.new(MILITARY, true, 4, given)
	state.choose(4, B)
	assert_eq(given, [A])
	assert_eq(state.choices, [A, B])
	state.choose(2, B)
	assert_eq(state.choices, [B, B])


func test_choose_reads_the_node_of_a_tier_as_dart_does() -> void:
	var state := TechBranchState.new(MILITARY)
	state.choose(3, B)
	assert_eq(state.choices, [B])
	state.choose(5, B)
	assert_eq(state.choices, [B, B])


func test_choose_before_the_first_choice_node_records_nothing() -> void:
	var state := TechBranchState.new(MILITARY, true, 2, [B])
	expect_error("TechBranchState.choose: no choice node at level 1")
	state.choose(1, A)
	assert_eq(state.choices, [B])


func test_option_at_refuses_a_choice_that_is_no_option() -> void:
	var state := TechBranchState.new(MILITARY, true, 4, [2, -1])
	expect_error("TechBranchState.option_at: the choice 2 is no option")
	assert_null(state.option_at(2))
	expect_error("TechBranchState.option_at: the choice -1 is no option")
	assert_null(state.option_at(4))


func test_perks_grant_nothing_once_a_node_has_no_option() -> void:
	expect_error("TechBranchState.perks: no option at level 6")
	assert_eq(TechBranchState.new(MILITARY, true, 6, [B, B]).perks(), {})
	expect_error("TechBranchState.option_at: the choice 7 is no option")
	expect_error("TechBranchState.perks: no option at level 2")
	assert_eq(TechBranchState.new(MILITARY, true, 2, [7]).perks(), {})


func test_perks_come_in_the_order_of_the_levels() -> void:
	var state := TechBranchState.new(TechBranch.Value.EXPLORER, true, 5, [B, A])
	assert_eq(state.perks().keys(), [TechPerk.Value.SILENT_SWIM, TechPerk.Value.WRECK_RAIDERS])
	var perks: Dictionary[TechPerk.Value, bool] = state.perks()
	assert_true(perks.has(TechPerk.Value.SILENT_SWIM))
