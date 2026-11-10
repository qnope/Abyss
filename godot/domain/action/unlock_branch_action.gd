class_name UnlockBranchAction
extends Action
## lib/domain/action/unlock_branch_action.dart: unlocks a branch of research
## once the laboratory stands, its cost growing with the branches opened.

var branch: TechBranch.Value


func _init(branch_: TechBranch.Value) -> void:
	branch = branch_


func type() -> ActionType.Value:
	return ActionType.Value.UNLOCK_BRANCH


func description() -> String:
	return "Debloquer branche TechBranch.%s" % DartEnum.name_of(TechBranch.Value, branch)


func validate(_game: Game, player: Player) -> ActionResult:
	var state: TechBranchState = player.tech_branches.get(branch)
	if state == null:
		return ActionResult.failure(ActionFailure.Value.BRANCH_NOT_FOUND)
	if state.unlocked:
		return ActionResult.failure(ActionFailure.Value.BRANCH_ALREADY_UNLOCKED)
	if Building.level_in(player.buildings, BuildingType.Value.LABORATORY) < 1:
		return ActionResult.failure(ActionFailure.Value.LABORATORY_REQUIRED)
	var costs := _costs(player)
	for resource: ResourceType.Value in costs:
		if GameResource.amount_in(player.resources, resource) < costs[resource]:
			return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var costs := _costs(player)
	for resource: ResourceType.Value in costs:
		player.resources[resource].amount -= costs[resource]
	player.tech_branches[branch].unlocked = true
	return ActionResult.success()


func make_history_entry(_game: Game, _player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
	return ResearchEntry.new(turn, branch, true)


func _costs(player: Player) -> Dictionary[ResourceType.Value, int]:
	return TechCostCalculator.unlock_cost(branch, TechCostCalculator.opened_branches(player.tech_branches))
