class_name ResearchTechAction
extends Action
## lib/domain/action/research_tech_action.dart: researches the next level
## of an unlocked branch at the laboratory, once a turn, taking `option`
## when that level is a choice.

var branch: TechBranch.Value
## Option taken when the next node is a choice; ignored on a tier.
var option: TechOption.Value


func _init(branch_: TechBranch.Value, option_ := TechOption.Value.A) -> void:
	branch = branch_
	option = option_


func type() -> ActionType.Value:
	return ActionType.Value.RESEARCH_TECH


func description() -> String:
	return "Rechercher tech TechBranch.%s" % DartEnum.name_of(TechBranch.Value, branch)


func validate(_game: Game, player: Player) -> ActionResult:
	var state: TechBranchState = player.tech_branches.get(branch)
	if state == null:
		return ActionResult.failure(ActionFailure.Value.BRANCH_NOT_FOUND)
	if not state.unlocked:
		return ActionResult.failure(ActionFailure.Value.BRANCH_LOCKED)
	if not player.worksite.can_research():
		return ActionResult.failure(ActionFailure.Value.RESEARCH_ALREADY_STARTED)
	var target_level := state.research_level + 1
	if target_level > TechCostCalculator.MAX_RESEARCH_LEVEL:
		return ActionResult.failure(ActionFailure.Value.MAX_LEVEL_REACHED)
	var lab_level := Building.level_in(player.buildings, BuildingType.Value.LABORATORY)
	if lab_level < TechCostCalculator.required_lab_level(target_level):
		return ActionResult.failure(ActionFailure.Value.LABORATORY_LEVEL_TOO_LOW)
	var costs := _costs(player, target_level)
	for resource: ResourceType.Value in costs:
		if GameResource.amount_in(player.resources, resource) < costs[resource]:
			return ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	return ActionResult.success()


func execute(game: Game, player: Player) -> ActionResult:
	var validation := validate(game, player)
	if not validation.is_success:
		return validation
	var state: TechBranchState = player.tech_branches[branch]
	var target_level := state.research_level + 1
	var costs := _costs(player, target_level)
	for resource: ResourceType.Value in costs:
		player.resources[resource].amount -= costs[resource]
	if TechTree.is_choice_level(target_level):
		state.choose(target_level, option)
	state.research_level = target_level
	player.worksite.research += 1
	return ActionResult.success()


func _costs(player: Player, level: int) -> Dictionary[ResourceType.Value, int]:
	return TechCostCalculator.research_cost(
		branch, level, TechCostCalculator.opened_branches(player.tech_branches)
	)


func make_history_entry(_game: Game, player: Player, _result: ActionResult, turn: int) -> HistoryEntry:
	return ResearchEntry.new(turn, branch, false, player.tech_branches[branch].research_level)
