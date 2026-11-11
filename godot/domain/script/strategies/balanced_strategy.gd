class_name BalancedStrategy
extends GameScript
## lib/domain/script/strategies/balanced_strategy.dart: "Équilibrée", spends
## part of each turn on defence (barracks, Coral Citadel, Military research,
## recruits) and the rest on production. Raids should not end it.
##
## Defenders come as one Gardien for every Harponneur and a half: Gardiens
## alone barely scratch level 3 monsters.

## EconomyStrategy.BUILD_ORDER, then the barracks, the Coral Citadel and the
## laboratory.
const BUILD_ORDER: Array[BuildingType.Value] = [
	BuildingType.Value.SOLAR_PANEL,
	BuildingType.Value.ALGAE_FARM,
	BuildingType.Value.CORAL_MINE,
	BuildingType.Value.ORE_EXTRACTOR,
	BuildingType.Value.HEADQUARTERS,
	BuildingType.Value.BARRACKS,
	BuildingType.Value.CORAL_CITADEL,
	BuildingType.Value.LABORATORY,
]

## Share of the affordable defenders recruited on a quiet turn.
var peace_recruit_share: float
## Share recruited while a raid is announced.
var alert_recruit_share: float


func _init(peace_recruit_share_ := 0.25, alert_recruit_share_ := 0.8) -> void:
	peace_recruit_share = peace_recruit_share_
	alert_recruit_share = alert_recruit_share_


func name() -> String:
	return "balanced"


func play_turn(turn: ScriptTurn) -> void:
	var alert := turn.player.raid_state.is_incoming()
	var share := alert_recruit_share if alert else peace_recruit_share
	if ScriptTurnMoves.best_defender(turn) == UnitType.Value.GUARDIAN:
		ScriptTurnMoves.recruit_share(turn, UnitType.Value.GUARDIAN, share / 3)
		ScriptTurnMoves.recruit_share(turn, UnitType.Value.HARPOONIST, share / 2)
	elif ScriptTurnMoves.best_defender(turn) != null:
		ScriptTurnMoves.recruit_share(turn, UnitType.Value.HARPOONIST, share)
	turn.try_perform(UnlockBranchAction.new(TechBranch.Value.MILITARY))
	turn.try_perform(GrowthMoves.research_next(turn, TechBranch.Value.MILITARY))
	ScriptTurnMoves.upgrade_in_order(turn, BUILD_ORDER)
