class_name TechView
extends RefCounted
## What the research tree reads of the game, taken at one moment: the
## branches, the laboratory, the stock and whether this turn's research is
## spent. It answers for each node and branch: how it stands
## (lib/presentation/widgets/tech/tech_reef.dart: nodeState), whether it is
## done, what blocks it and what it costs
## (tech_target_panel.dart). The parts of the tree and of the panel are built
## from it, so that each is tested on its own; they are built again from a
## new view after each change.

var branches: Dictionary[TechBranch.Value, TechBranchState]
var buildings: Dictionary[BuildingType.Value, Building]
var resources: Dictionary[ResourceType.Value, GameResource]
## The turn's research was made: no other until the next turn.
var research_done: bool
var lab_level: int
## The branches unlocked.
var opened: int


## The view of the human player of [param game].
static func of(game: Game) -> TechView:
	var human := game.human_player()
	var view := TechView.new()
	view.branches = human.tech_branches
	view.buildings = human.buildings
	view.resources = human.resources
	view.research_done = not human.worksite.can_research()
	view.lab_level = Building.level_in(human.buildings, BuildingType.Value.LABORATORY)
	view.opened = TechCostCalculator.opened_branches(human.tech_branches)
	return view


## The state of [param branch], null if the player has none.
func state_of(branch: TechBranch.Value) -> TechBranchState:
	var state: TechBranchState = branches.get(branch)
	return state


## The research level [param branch] has reached.
func research_level(branch: TechBranch.Value) -> int:
	var state := state_of(branch)
	return state.research_level if state != null else 0


func is_unlocked(branch: TechBranch.Value) -> bool:
	var state := state_of(branch)
	return state != null and state.unlocked


## How the node of [param level] of [param branch] stands; [param option] is
## the TechOption of a node of a choice level, null on the others.
func node_state(branch: TechBranch.Value, level: int, option: Variant = null) -> TechNodeState.Value:
	if not is_unlocked(branch):
		return TechNodeState.Value.LOCKED
	var reached := research_level(branch)
	if level <= reached:
		var taken: Variant = state_of(branch).option_at(level)
		return TechNodeState.Value.RESEARCHED if option == null or taken == option \
			else TechNodeState.Value.DISCARDED
	var reachable := level == reached + 1 and lab_level >= TechCostCalculator.required_lab_level(level)
	return TechNodeState.Value.ACCESSIBLE if reachable else TechNodeState.Value.LOCKED


## Whether [param target] is already unlocked or researched.
func is_done(target: TechTarget) -> bool:
	if target.is_branch():
		return is_unlocked(target.branch)
	return target.level <= research_level(target.branch)


func check(target: TechTarget) -> TechCheck:
	if target.is_branch():
		return TechCostCalculator.check_unlock(target.branch, resources, buildings, branches)
	return TechCostCalculator.check_research(target.branch, target.level, resources, buildings, branches)


## Why [param target] cannot be acted on yet, in the language on; "" when
## nothing stands in the way (the stock apart: the costs show in red).
func blocker(target: TechTarget) -> String:
	var verdict := check(target)
	if verdict.branch_locked:
		return Texts.t(&"techScreenUnlockBranchFirst")
	if verdict.previous_node_missing:
		return Texts.t(&"techScreenResearchPreviousFirst", {"level": target.level - 1})
	if verdict.current_lab_level < verdict.required_lab_level:
		return Texts.t(&"techScreenLabRequired", {"level": verdict.required_lab_level})
	if not target.is_branch() and research_done:
		return Texts.t(&"techScreenOneResearchPerTurn")
	return ""


## Whether the player can unlock or research [param target] right now.
func can_act(target: TechTarget) -> bool:
	return not is_done(target) and check(target).can_act and blocker(target).is_empty()


## What [param target] costs, with the branches opened counted in.
func costs(target: TechTarget) -> Dictionary[ResourceType.Value, int]:
	if target.is_branch():
		return TechCostCalculator.unlock_cost(target.branch, opened)
	return TechCostCalculator.research_cost(target.branch, target.level, opened)


## The factor every cost grows by once one more branch is open (1.5 for the
## second, 2 for the third).
func surcharge_factor() -> float:
	return TechCostCalculator.cost_percent(opened + 1) / 100.0
