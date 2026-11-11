class_name GrowthMoves
extends RefCounted
## lib/domain/script/strategies/growth_moves.dart: growth moves of a player
## who watches the energy balance and follows a research plan. The Dart
## extension on ScriptTurn: each function takes the turn first.

const Branch := TechBranch.Value
const Option := TechOption.Value

## Research plan: production first, then the army, one node at a time.
const RESEARCH_PLAN: Array[Branch] = [
	Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES, Branch.MILITARY, Branch.MILITARY,
	Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES,
]

## Options a defensive player takes at the choice nodes 2 and 4, by branch
## (each an Array of TechOption.Value).
const PICKS: Dictionary[Branch, Array] = {
	Branch.MILITARY: [Option.B, Option.A],
	Branch.RESOURCES: [Option.A, Option.A],
	Branch.EXPLORER: [Option.B, Option.B],
}


## Unlocks and researches the next nodes of `plan` it can pay, with the
## options of `picks`. An Explorer node it cannot pay is passed over for the
## next entry; any other shortfall waits for a later turn.
static func research(
	turn: ScriptTurn, plan: Array[Branch] = RESEARCH_PLAN, picks: Dictionary[Branch, Array] = PICKS
) -> void:
	var planned: Dictionary[Branch, int] = {}
	for branch: Branch in plan:
		var target: int = planned.get(branch, 0) + 1
		planned[branch] = target
		var state: TechBranchState = turn.player.tech_branches[branch]
		if state.research_level >= target:
			continue
		if not state.unlocked:
			var unlock := UnlockBranchAction.new(branch)
			if not turn.try_perform(unlock):
				if _passes_over(turn, branch, unlock):
					continue
				return
		var next := research_next(turn, branch, picks)
		if not turn.try_perform(next) and not _passes_over(turn, branch, next):
			return


## Whether the plan goes on past `step` of `branch`: only an Explorer node
## short of resources is passed over.
static func _passes_over(turn: ScriptTurn, branch: Branch, step: Action) -> bool:
	return (
		branch == Branch.EXPLORER
		and not turn.is_over()
		and step.validate(turn.game, turn.player).reason == ActionFailure.Value.NOT_ENOUGH_RESOURCES
	)


## Research of the next node of `branch`, with the option of `picks`.
static func research_next(
	turn: ScriptTurn, branch: Branch, picks: Dictionary[Branch, Array] = PICKS
) -> ResearchTechAction:
	var level := turn.player.tech_branches[branch].research_level + 1
	var option := Option.A
	if TechTree.is_choice_level(level):
		var options: Array = picks[branch]
		option = options[TechTree.choice_index(level)]
	return ResearchTechAction.new(branch, option)


## Energy produced minus energy the buildings and the heating of the farms
## use this turn.
static func energy_margin(turn: ScriptTurn) -> int:
	var player := turn.player
	var made := ProductionCalculator.from_buildings(player.buildings, player.tech_branches)
	var produced: int = made.get(ResourceType.Value.ENERGY, 0)
	return produced - TurnProduction.energy_consumption(player, turn.game.turn)


## Raises the buildings of `order` one level at a time, round after round,
## skipping any upgrade that would leave the base short of energy (Solar
## Panels first in that case).
static func grow_in_order(turn: ScriptTurn, order: Array[BuildingType.Value]) -> void:
	var player := turn.player
	var progressed := true
	while progressed and not turn.is_over():
		progressed = false
		for type: BuildingType.Value in order:
			var level := player.buildings[type].level
			var extra := (
				ConsumptionCalculator.building_energy_consumption(type, level + 1)
				- ConsumptionCalculator.building_energy_consumption(type, level)
			)
			var stock := player.resources[ResourceType.Value.ENERGY].amount
			if type != BuildingType.Value.SOLAR_PANEL and energy_margin(turn) - extra + DartMath.trunc_div(stock, 10) < 0:
				if turn.try_perform(UpgradeBuildingAction.new(BuildingType.Value.SOLAR_PANEL)):
					progressed = true
				continue
			if turn.try_perform(UpgradeBuildingAction.new(type)):
				progressed = true
