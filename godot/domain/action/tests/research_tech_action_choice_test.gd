extends TestCase
## test/domain/action/research_tech_action_choice_test.dart: the option
## taken at a choice node, and the cost of the branches opened.

const MILITARY := TechBranch.Value.MILITARY
const A := TechOption.Value.A
const B := TechOption.Value.B


func _scenario(states: Array[TechBranchState]) -> Player:
	var stocks := DomainSamples.resources(ActionSamples.amounts(900, 900, 900, 900, 900), 1000)
	return Player.new(
		"Test", "test", 0, 0, stocks, DomainSamples.buildings({BuildingType.Value.LABORATORY: 5}),
		TechHelpers.tech_branches_with(states),
	)


func _research(player: Player, option := A) -> ActionResult:
	return ResearchTechAction.new(MILITARY, option).execute(ActionSamples.game_of(player), player)


func _military(player: Player) -> TechBranchState:
	return player.tech_branches[MILITARY]


func test_researching_a_choice_node_records_the_option_taken() -> void:
	var player := _scenario([TechHelpers.researched_branch(MILITARY, 1)])
	assert_true(_research(player, B).is_success)
	assert_eq(_military(player).research_level, 2)
	assert_eq(_military(player).option_at(2), B)
	assert_eq(_military(player).perks(), {TechPerk.Value.NACRE_SHELL: true})


func test_the_option_defaults_to_a() -> void:
	var options: Array[TechOption.Value] = [B]
	var player := _scenario([TechHelpers.researched_branch(MILITARY, 3, options)])
	ResearchTechAction.new(MILITARY).execute(ActionSamples.game_of(player), player)
	assert_eq(_military(player).choices, [B as int, A as int])


func test_a_tier_node_ignores_the_option() -> void:
	var options: Array[TechOption.Value] = [A]
	var player := _scenario([TechHelpers.researched_branch(MILITARY, 2, options)])
	_research(player, B)
	assert_eq(_military(player).research_level, 3)
	assert_eq(_military(player).choices, [A as int])


func test_a_failed_research_records_no_choice() -> void:
	var player := _scenario([TechHelpers.researched_branch(MILITARY, 1)])
	player.buildings[BuildingType.Value.LABORATORY].level = 1
	assert_false(_research(player, B).is_success)
	assert_true(_military(player).choices.is_empty())


func test_the_cost_grows_with_every_other_branch_opened() -> void:
	var player := _scenario([
		TechHelpers.researched_branch(MILITARY, 0),
		TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 0),
	])
	_research(player)
	# Level 1 costs ore 80 / energy 50, x1.5 with two branches opened.
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 900 - 120)
	assert_eq(player.resources[ResourceType.Value.ENERGY].amount, 900 - 75)
