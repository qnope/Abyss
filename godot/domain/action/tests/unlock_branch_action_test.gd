extends TestCase
## test/domain/action/unlock_branch_action_test.dart: unlocking a branch of
## research at the laboratory.

const MILITARY := TechBranch.Value.MILITARY

var action: UnlockBranchAction


func before_each() -> void:
	action = UnlockBranchAction.new(MILITARY)


func _scenario(lab_level := 1, ore := 100, energy := 100, military_unlocked := false) -> Player:
	var player := ActionSamples.stocked(
		ActionSamples.amounts(100, 100, ore, energy, 50), {BuildingType.Value.LABORATORY: lab_level}
	)
	player.tech_branches = TechHelpers.tech_branches_with([TechBranchState.new(MILITARY, military_unlocked)])
	return player


func _validate(player: Player) -> ActionResult:
	return action.validate(ActionSamples.game_of(player), player)


func test_validate_success_case() -> void:
	assert_true(_validate(_scenario()).is_success)


func test_validate_a_branch_the_player_does_not_have_cannot_be_unlocked() -> void:
	var player := _scenario()
	player.tech_branches.erase(MILITARY)
	assert_eq(action.execute(ActionSamples.game_of(player), player).reason, ActionFailure.Value.BRANCH_NOT_FOUND)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 100)
	assert_false(player.tech_branches.has(MILITARY))


func test_validate_lab_not_built_returns_failure() -> void:
	assert_false(_validate(_scenario(0)).is_success)


func test_validate_branch_already_unlocked_returns_failure() -> void:
	assert_false(_validate(_scenario(1, 100, 100, true)).is_success)


func test_validate_insufficient_resources_returns_failure() -> void:
	assert_false(_validate(_scenario(1, 0, 0)).is_success)


func test_execute_success_resources_deducted_and_branch_unlocked() -> void:
	var player := _scenario()
	assert_true(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 70)
	assert_eq(player.resources[ResourceType.Value.ENERGY].amount, 80)
	assert_true(player.tech_branches[MILITARY].unlocked)


func test_execute_failure_game_state_unchanged() -> void:
	var player := _scenario(1, 0, 0)
	assert_false(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 0)
	assert_eq(player.resources[ResourceType.Value.ENERGY].amount, 0)
	assert_false(player.tech_branches[MILITARY].unlocked)


## Not in the Dart file: the reasons of each refusal, and the description.
func test_each_refusal_has_its_reason() -> void:
	assert_eq(_validate(_scenario(0)).reason, ActionFailure.Value.LABORATORY_REQUIRED)
	assert_eq(_validate(_scenario(1, 100, 100, true)).reason, ActionFailure.Value.BRANCH_ALREADY_UNLOCKED)
	assert_eq(_validate(_scenario(1, 0, 0)).reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	assert_eq([action.type(), action.description()], [ActionType.Value.UNLOCK_BRANCH, "Debloquer branche TechBranch.military"])
