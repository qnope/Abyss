extends TestCase
## test/domain/action/research_tech_action_test.dart: researching the next
## level of a branch.

const MILITARY := TechBranch.Value.MILITARY

var action: ResearchTechAction


func before_each() -> void:
	action = ResearchTechAction.new(MILITARY)


func _scenario(lab_level := 1, ore := 500, energy := 500, unlocked := true, research_level := 0) -> Player:
	var player := ActionSamples.stocked(
		ActionSamples.amounts(500, 500, ore, energy, 50), {BuildingType.Value.LABORATORY: lab_level}
	)
	player.tech_branches = TechHelpers.tech_branches_with([TechBranchState.new(MILITARY, unlocked, research_level)])
	return player


func _validate(player: Player) -> ActionResult:
	return action.validate(ActionSamples.game_of(player), player)


func test_validate_success_branch_unlocked_lab_level_ok_resources_ok() -> void:
	assert_true(_validate(_scenario()).is_success)


func test_validate_a_branch_the_player_does_not_have_cannot_be_researched() -> void:
	var player := _scenario()
	player.tech_branches.erase(MILITARY)
	assert_eq(action.execute(ActionSamples.game_of(player), player).reason, ActionFailure.Value.BRANCH_NOT_FOUND)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 500)
	assert_eq(player.worksite.research, 0)


func test_validate_branch_locked_returns_failure() -> void:
	assert_false(_validate(_scenario(1, 500, 500, false)).is_success)


func test_validate_max_level_reached_returns_failure() -> void:
	assert_false(_validate(_scenario(5, 500, 500, true, 5)).is_success)


func test_validate_lab_level_too_low_returns_failure() -> void:
	assert_false(_validate(_scenario(1, 500, 500, true, 1)).is_success)


func test_validate_insufficient_resources_returns_failure() -> void:
	assert_false(_validate(_scenario(1, 0, 0)).is_success)


func test_execute_success_resources_deducted_research_level_incremented() -> void:
	var player := _scenario()
	assert_true(action.execute(ActionSamples.game_of(player), player).is_success)
	# military level 1 costs ore: 40, energy: 25
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 420)
	assert_eq(player.resources[ResourceType.Value.ENERGY].amount, 450)
	assert_eq(player.tech_branches[MILITARY].research_level, 1)


func test_execute_failure_game_state_unchanged() -> void:
	var player := _scenario(1, 0, 0)
	assert_false(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 0)
	assert_eq(player.resources[ResourceType.Value.ENERGY].amount, 0)
	assert_eq(player.tech_branches[MILITARY].research_level, 0)


## Not in the Dart file: the reasons of each refusal, and the description.
func test_each_refusal_has_its_reason() -> void:
	assert_eq(_validate(_scenario(1, 500, 500, false)).reason, ActionFailure.Value.BRANCH_LOCKED)
	assert_eq(_validate(_scenario(5, 500, 500, true, 5)).reason, ActionFailure.Value.MAX_LEVEL_REACHED)
	assert_eq(_validate(_scenario(1, 500, 500, true, 1)).reason, ActionFailure.Value.LABORATORY_LEVEL_TOO_LOW)
	assert_eq(_validate(_scenario(1, 0, 0)).reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	assert_eq([action.type(), action.description()], [ActionType.Value.RESEARCH_TECH, "Rechercher tech TechBranch.military"])
