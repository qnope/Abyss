class_name ScriptTurnMoves
extends RefCounted
## lib/domain/script/strategies/script_turn_moves.dart: common moves the
## built-in strategies are made of. The Dart extension on ScriptTurn: each
## function takes the turn first.


## Raises the buildings of `order` one level at a time, round after round,
## until none of them can go up anymore.
static func upgrade_in_order(turn: ScriptTurn, order: Array[BuildingType.Value]) -> void:
	var progressed := true
	while progressed and not turn.is_over():
		progressed = false
		for type: BuildingType.Value in order:
			if turn.try_perform(UpgradeBuildingAction.new(type)):
				progressed = true


## Recruits `share` (0 to 1) of the most `type` units affordable now;
## returns how many joined.
static func recruit_share(turn: ScriptTurn, type: UnitType.Value, share: float) -> int:
	var player := turn.player
	var barracks := Building.level_in(player.buildings, BuildingType.Value.BARRACKS)
	var affordable := UnitCostCalculator.new().max_recruitable_count(
		type, barracks, player.resources, player.is_degraded(BuildingType.Value.BARRACKS)
	)
	var count := floori(affordable * share)
	if count <= 0:
		return 0
	var action := RecruitUnitAction.new(type, count)
	return count if turn.try_perform(action) else 0


## Best defender the barracks can train (a UnitType.Value), or null before
## it is built.
static func best_defender(turn: ScriptTurn) -> Variant:
	var barracks := Building.level_in(turn.player.buildings, BuildingType.Value.BARRACKS)
	var costs := UnitCostCalculator.new()
	if costs.is_unlocked(UnitType.Value.GUARDIAN, barracks):
		return UnitType.Value.GUARDIAN
	if costs.is_unlocked(UnitType.Value.HARPOONIST, barracks):
		return UnitType.Value.HARPOONIST
	return null
