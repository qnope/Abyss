class_name FactionSpyScout
extends RefCounted
## lib/domain/faction/faction_spy_scout.dart: a faction spies before it
## strikes: it keeps a Scout at home for its war slot, whatever the
## exploration left.


## Recruits the Scout of the slot when none is home. A unit type is recruited
## once a turn, so the recruit also takes what the exploration needs, or the
## scouting would wait a turn; a faction too poor for all of it still takes
## the one Scout.
static func keep(turn: ScriptTurn, personality: FactionPersonality.Value) -> void:
	var home := Unit.count_in(turn.player.units_on_level(RaidBattle.BASE_LEVEL), UnitType.Value.SCOUT)
	if home > 0:
		return
	var need := ScoutMoves.scouts_wanted(
		turn,
		FactionTraits.of(personality).explorers,
		FactionScouting.deep_scouts_of(personality),
		true,
	)
	if need > 0 and _recruit(turn, need + 1):
		return
	_recruit(turn, 1)


static func _recruit(turn: ScriptTurn, quantity: int) -> bool:
	return turn.try_perform(RecruitUnitAction.new(UnitType.Value.SCOUT, quantity))
