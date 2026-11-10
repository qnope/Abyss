class_name FightCasualtyBreakdown
extends RefCounted
## lib/domain/action/fight_casualty_breakdown.dart: summary of the
## post-fight unit outcome for the player side.
##
## Produced by `FightMonsterHelpers.resolve_casualties` so the fight action
## can populate its result and history entry from a single value.

var survivors_intact: Dictionary[UnitType.Value, int]
var wounded: Dictionary[UnitType.Value, int]
var dead: Dictionary[UnitType.Value, int]


func _init(
	survivors_intact_: Dictionary[UnitType.Value, int],
	wounded_: Dictionary[UnitType.Value, int],
	dead_: Dictionary[UnitType.Value, int],
) -> void:
	survivors_intact = survivors_intact_
	wounded = wounded_
	dead = dead_
